FROM ubuntu:18.04
LABEL Maintainer="Sakly Ayoub"
ENV DEBIAN_FRONTEND noninteractive
#
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
    nano \
    graphicsmagick \
    imagemagick \
    ghostscript \
    iputils-ping \
    nodejs \
    npm \
    locales \
    wget \
    git \
    zip \
    mysql-client \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#
# Generate locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8 && \
    a2enmod rewrite expires
#
# Install IonCube Loader
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir /ioncube && \
    cd /ioncube && \
    wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && \
    tar xvf ioncube_loaders_lin_x86-64.tar.gz && \
    cp /ioncube/ioncube/ioncube_loader_lin_7.3.so /usr/lib/php/20180731 && \
    echo zend_extension = /usr/lib/php/20180731/ioncube_loader_lin_7.3.so > /etc/php/7.3/cli/php.ini && \
    echo zend_extension = /usr/lib/php/20180731/ioncube_loader_lin_7.3.so > /etc/php/7.3/apache2/conf.d/00-ioncube.ini && \
    rm -rf /ioncube/ioncube/
#
# Make php.ini editibale from ENV VARS
RUN echo 'memory_limit = "${PHP_MEMORY_LIMIT}"' >> /etc/php/7.3/apache2/conf.d/php.ini && \
    echo 'upload_max_filesize = "${PHP_MAX_FILESIZE}"' >> /etc/php/7.3/apache2/conf.d/php.ini && \
    echo 'upload_max_filesize = "${PHP_MAX_FILESIZE}"' >> /etc/php/7.3/apache2/conf.d/php.ini && \
    echo 'post_max_size = "${PHP_POST_MAX_SIZE}"' >> /etc/php/7.3/apache2/conf.d/php.ini && \
    echo 'max_input_vars = "${PHP_INPUT_VARS}"' >> /etc/php/7.3/apache2/conf.d/php.ini
#
# Add Custom Tiny File Manager
RUN git clone https://github.com/mindhosting/filemanager.git /var/www/filemanager && \
    rm -r /var/www/filemanager/.git && \
    chown -R www-data:www-data /var/www/filemanager
#
# ADD PhpMyAdmin
RUN wget -O /tmp/phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/4.8.2/phpMyAdmin-4.8.2-all-languages.tar.gz && \
    tar xfvz /tmp/phpmyadmin.tar.gz -C /var/www && \
    mv /var/www/phpMyAdmin-4.8.2-all-languages /var/www/phpmyadmin && \
    echo "<?php" >> /var/www/phpmyadmin/config.inc.php && \
    echo "\$i++;">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['auth_type'] = 'cookie';">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['host'] = 'db';">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['connect_type'] = 'tcp';">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['compress'] = false;">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['extension'] = 'mysql';">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['controluser'] = '';">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['controlpass'] = '';">> /var/www/phpmyadmin/config.inc.php && \
    echo "\$cfg['Servers'][$i]['hide_db'] = 'information_schema';">> /var/www/phpmyadmin/config.inc.php && \
    chmod 544 /var/www/phpmyadmin/config.inc.php
#
# Create defautl site in apache
ADD default.conf /etc/apache2/sites-enabled/000-default.conf
#
# Configure WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
#
# Finxing permerssion and printing logs as output
RUN chown -R www-data:www-data /var/www/html && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log
#
# Declaring volumes
WORKDIR /var/www/html
RUN rm /var/www/html/index.html
VOLUME /var/www/html
#
# Exposing ports
EXPOSE 80
#
# Declaring entrypoint
COPY entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]
#
# ADD HEATHCHECK TETS
#HEALTHCHECK CMD curl --fail http://localhost:80 || exit 1
CMD ["apache2ctl", "-D", "FOREGROUND"]
