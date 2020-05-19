FROM mindhosting/apachephp:7.2
LABEL Maintainer="Sakly Ayoub"
ENV DEBIAN_FRONTEND noninteractive
#
# Configure WP CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
#
# Declaring volumes
WORKDIR /var/www/html
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
