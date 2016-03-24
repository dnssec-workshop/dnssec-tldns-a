# Image: dnssec-tldns-a
# Startup a docker container as BIND master for DNS TLDs

FROM dnssecworkshop/dnssec-bind

MAINTAINER dape16 "dockerhub@arminpech.de"

LABEL RELEASE=20160324-2216

# Set timezone
ENV     TZ=Europe/Berlin
RUN     ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install software
RUN     apt-get update
RUN     apt-get upgrade -y
RUN     echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN     echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN     apt-get install -y --no-install-recommends apache2 mysql-server golang-go

# Deploy DNSSEC workshop material
RUN     cd /root && git clone https://github.com/dnssec-workshop/dnssec-data && \
          rsync -v -rptgoD --copy-links /root/dnssec-data/dnssec-tldns-a/ /

# Configure webserver
RUN     a2dissite 000-default
RUN     a2ensite sld-registrar
RUN     a2enmod proxy proxy_http

# Setup dataabase for whois/registrar service
RUN     /usr/bin/mysql_install_db --user mysql
RUN     /usr/sbin/mysqld --bootstrap --verbose=1 --init-file=/etc/mysql/init-db.sql
RUN     /usr/sbin/mysqld --bootstrap --verbose=1 --init-file=/etc/whoisd/sld.sql

# Start services using supervisor
RUN     mkdir -p /var/log/supervisor

EXPOSE  22 53 80
CMD     [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/dnssec-tldns-a.conf" ]

# vim: set syntax=docker tabstop=2 expandtab:
