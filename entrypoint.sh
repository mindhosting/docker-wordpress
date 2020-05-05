#!/bin/bash
set -euo pipefail
logo_print(){
        cat << "EOF"

    ███╗   ███╗██╗███╗   ██╗██████╗     ██╗  ██╗ ██████╗ ███████╗████████╗██╗███╗   ██╗ ██████╗ 
    ████╗ ████║██║████╗  ██║██╔══██╗    ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝ 
    ██╔████╔██║██║██╔██╗ ██║██║  ██║    ███████║██║   ██║███████╗   ██║   ██║██╔██╗ ██║██║  ███╗
    ██║╚██╔╝██║██║██║╚██╗██║██║  ██║    ██╔══██║██║   ██║╚════██║   ██║   ██║██║╚██╗██║██║   ██║
    ██║ ╚═╝ ██║██║██║ ╚████║██████╔╝    ██║  ██║╚██████╔╝███████║   ██║   ██║██║ ╚████║╚██████╔╝
    ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
                                                                                         PHP 7.3
    WORDPRESS CONTAINER (R) AVRIL2020 V0.1
    FOR MIND HOSTING
    https://mind.hosting
    by SAKLY Ayoub
    saklyayoub@gmail.com

EOF
}
apache_set_servername(){
    echo "ServerName "$VIRTUAL_HOST >> /etc/apache2/apache2.conf
    echo "[OK] APACHE SERVER NAME CONFIGURED"
}
wp_setup_files(){
    if [[ -z "$(ls -A /web_data/public_html)" ]]; then
        cp -ar /web_data/wordpress/. /web_data/public_html
        rm -r /web_data/wordpress
        echo "[OK] WEB DIRECTORY POPULATED WITH WORDPRESS FILES"
    fi    
}
wp_update_config(){
    if [[ ! -f /web_data/public_html/wp-config.php ]]; then
        mv /web_data/public_html/wp-config-sample.php /web_data/public_html/wp-config.php
        echo "[OK] CONFIG FILE DOESN'T EXIST, NEW ONE HAS BEEN CREATED"
    fi
    echo "[CHECK] CONFIG FILE HASE BEEN CREATED"
    sed -i "/DB_NAME/c\define( 'DB_NAME', '"$ADMIN_USERNAME"' );" /web_data/public_html/wp-config.php
    sed -i "/DB_USER/c\define( 'DB_USER', '"$ADMIN_USERNAME"' );" /web_data/public_html/wp-config.php
    sed -i "/DB_PASSWORD/c\define( 'DB_PASSWORD', '"$ADMIN_PASSWORD"' );" /web_data/public_html/wp-config.php
    sed -i "/DB_HOST/c\define( 'DB_HOST', 'db' );" /web_data/public_html/wp-config.php
    echo "[OK] WORDPRESS CONFIG FILE UPDATED"
}
wp_securing_web(){
    chown -R www-data:www-data /web_data/public_html
    chmod -R 0755 /web_data/public_html
    find /web_data/public_html -type f -exec chmod 0644 {} \;
    chmod 0444 /web_data/public_html/wp-config.php
    echo "[OK] WORDPRESS WEB SECURED"
}
wp_setup_database(){
    if [[ -f /web_data/db_data/$ADMIN_USERNAME/wp_users.frm ]] && [[ -f /web_data/db_data/$ADMIN_USERNAME/wp_users.ibd ]]; then
        echo "[CHECK] WORDPRESS DATABASE ALRADY INITILIZED"
    else
        i=0
        WP_DATABASE=false
        while [ $i -le 10 ] && [ !${WP_DATABASE} ];
        do
                sleep 5
                curl --fail http://db:3306 1>/dev/null 2>&1;
                if [[ $? -eq 0 ]]; then
                        cd /web_data/public_html/
                        wp core install --url=$WP_URL  --title=$WP_TITLE --admin_user=$ADMIN_USERNAME --admin_password=$ADMIN_PASSWORD --admin_email=$ADMIN_EMAIL --skip-email $
                        if [[ $? -eq 0 ]]; then
                                echo "[OK] WORDPRESS DATABASE INSTALLED SUCCEFULLY"
                                WP_DATABASE=true
                        else
                                echo "[ERROR] FAILED TO INSTALL WORDPRESS DATABASE"
                        fi
                        break
                else
                        ((i++))
                        echo"[WAITING] DATABASE SERVER NOT YET READY FOR CONNEXION, NETX TRY IN 5 SECONDS"
                fi
        done

    fi
}
if [[ "$1" == apache2* ]]; then
    logo_print
    echo "[Initilizing ...]"
    echo ""
    apache_set_servername
    wp_setup_files
    wp_update_config
    wp_securing_web
    wp_setup_database
    echo ""
    echo ""
    echo "**** WORDPRESS CONTAINER STARED SUCCESSFULY ****"
    echo "below there will be the instant apache access and error log"
    echo ""
    echo ""
fi
exec "$@"
