FROM debian:bullseye

LABEL maintainer="cmanriquez"
# Dockerfile creado por cmanriquez para contenedor Nagios Core

ENV NAGIOS_USER=nagios
ENV NAGIOS_GROUP=nagios

# Instala dependencias necesarias
RUN apt-get update && \
    apt-get install -y wget build-essential apache2 php gcc make libgd-dev unzip libapache2-mod-php curl libssl-dev openssl apache2-utils

# Crea grupo y usuario solo si no existen
RUN groupadd -f $NAGIOS_GROUP && \
    id -u $NAGIOS_USER &>/dev/null || useradd -m -g $NAGIOS_GROUP $NAGIOS_USER && \
    usermod -a -G $NAGIOS_GROUP www-data

# Descargar y compilar Nagios Core
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

# Descargar e instalar Nagios Plugins
RUN wget https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz && \
    tar -xzf nagios-plugins-2.3.3.tar.gz && \
    cd nagios-plugins-2.3.3 && \
    ./configure && make && make install

# Configura autenticación web y habilita CGI en Apache
RUN htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin && \
    a2enmod cgi

# Expone el puerto web de Nagios
EXPOSE 80

# Comando para iniciar Nagios y mantener contenedor activo
CMD ["/bin/bash", "-c", "service apache2 start && /usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg && tail -f /var/log/apache2/error.log"]
