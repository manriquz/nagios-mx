FROM debian:bullseye

LABEL maintainer="cmanriquez"
# Dockerfile creado por cmanriquez para contenedor Nagios Core

ENV NAGIOS_USER nagios
ENV NAGIOS_GROUP nagios

RUN apt-get update && \
    apt-get install -y wget build-essential apache2 php gcc make libgd-dev unzip libapache2-mod-php curl libssl-dev openssl

RUN useradd $NAGIOS_USER && \
    groupadd $NAGIOS_GROUP && \
    usermod -a -G $NAGIOS_GROUP www-data

WORKDIR /tmp
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.14.tar.gz && \
    tar -xzf nagios-4.4.14.tar.gz && \
    cd nagios-4.4.14 && \
    ./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
    make all && \
    make install && \
    make install-init && \
    make install-config && \
    make install-commandmode && \
    make install-webconf

RUN wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz && \
    tar -xzf nagios-plugins-2.3.3.tar.gz && \
    cd nagios-plugins-2.3.3 && \
    ./configure && make && make install

RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin && \
    a2enmod cgi

EXPOSE 80

CMD ["/bin/bash", "-c", "service apache2 start && /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg && tail -f /var/log/apache2/error.log"]
