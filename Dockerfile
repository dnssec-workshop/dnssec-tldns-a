# Image: dnssec-tldns-a
# Startup a docker container as BIND master for DNS TLDs

FROM dnssecworkshop/dnssec-bind

MAINTAINER dape16 "dockerhub@arminpech.de"

LABEL RELEASE=20160325-2315

# Set timezone
ENV     TZ=Europe/Berlin
RUN     ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install software
RUN     apt-get update
RUN     apt-get upgrade -y
RUN     echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN     echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
          apache2 mysql-server golang-go

# Deploy DNSSEC workshop material
RUN     cd /root && git clone https://github.com/dnssec-workshop/dnssec-data && \
          rsync -v -rptgoD --copy-links /root/dnssec-data/dnssec-tldns-a/ /

# Configure webserver
RUN     a2dissite 000-default
RUN     a2ensite sld-registrar
RUN     a2enmod proxy proxy_http

# Setup database for whois/registrar service
RUN     chmod 750 /etc/mysql/config-db.sh
RUN     /etc/mysql/config-db.sh

# Start services using supervisor
RUN     mkdir -p /var/log/supervisor

EXPOSE  22 53 80
CMD     [ "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/dnssec-tldns-a.conf" ]

# vim: set syntax=docker tabstop=2 expandtab:
