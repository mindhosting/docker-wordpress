FROM ubuntu:18.04
LABEL Maintainer="Sakly Ayoub"
ENV DEBIAN_FRONTEND noninteractive

# Install Apache & PHP7.3
RUN apt-get update -yq && apt-get upgrade -yq && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:ondrej/php
RUN apt-get update -yq && \
    apt-get install -y \
    apt-utils \
    curl \
    apache2 \
    libapache2-mod-php7.3 \
    php7.3 \
    php7.3-cli \
    php7.3-json \
    php7.3-curl \
    php7.3-fpm \
    php7.3-gd \
    php7.3-ldap \
    php7.3-mbstring \
    php7.3-mysql \
    php7.3-soap \
    php7.3-sqlite3 \
    php7.3-xml \
    php7.3-zip \
    php7.3-intl \
    php7.3-imap \
    php7.3-recode \
    php7.3-tidy \
    php7.3-xmlrpc \
    php-imagick \
    graphicsmagick \
    imagemagick \
    ghostscript \
    iputils-ping \
    locales \
    wget \
    git \
    zip \
    mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8 && \
    a2enmod rewrite expires

# Fixing PHP & Apache configuration
ADD php.ini /etc/php/7.3/apache2/conf.d/
ADD default.conf /etc/apache2/sites-enabled/000-default.conf

# Declaring entrypoint
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

#Add Custom Tiny File Manager
RUN git clone https://github.com/mindhosting/filemanager.git /var/www/filemanager && \
    rm -r /var/www/filemanager/.git && \
    chown -R www-data:www-data /var/www/filemanager

# Configure WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Declaring volumes
VOLUME web_data/public_html

# Exposing ports
EXPOSE 80

# Finxing permerssion and printing los as output
RUN chown -R www-data:www-data /web_data/public_html && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
# ADD HEATHCHECK TETS
#HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ["apache2ctl", "-D", "FOREGROUND"]
