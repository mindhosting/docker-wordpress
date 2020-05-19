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
                                                                                         PHP 7.4
    WORDPRESS CONTAINER (R) AVRIL2020 V1.0
    FOR MIND HOSTING
    https://mind.hosting
    by SAKLY Ayoub
    saklyayoub@gmail.com

EOF
}
apache_set_servername(){
	echo "ServerName "$VIRTUAL_HOST >> /etc/apache2/apache2.conf
}

wp_install(){
	if [[ -z "$(ls -A /var/www/html)" ]]; then
        	cd /var/www/html
		touch lock.tmp
	        wp core download --allow-root
		rm lock.tmp
	        i=0
        	WP_DATABASE=false
	        while [[ $i -le 6 ]] && [[ !${WP_DATABASE} ]];
	        do
	                curl --fail http://db:3306 1>/dev/null 2>&1;
	                if [[ $? -eq 0 ]]; then
	                        cd /var/www/html/
				wp core config --dbname=$ADMIN_USERNAME --dbuser=$ADMIN_USERNAME --dbpass=$ADMIN_PASSWORD --dbhost=db --dbprefix=wp_ --extra-php --allow-root
	                        wp core install --url="https://"$VIRTUAL_HOST  --title="Blog" --admin_user=$ADMIN_USERNAME --admin_password=$ADMIN_PASSWORD --admin_email=$ADMIN_EMAIL --skip-email --allow-root
	                        if [[ $? -eq 0 ]]; then
	                                WP_DATABASE=true
	                                break
	                        fi
	                else
	                        ((i++))
	                        echo "Alert: database server not yet ready for connecion... retry in 10 Sec"
				sleep 5
	                fi
	        done
	        chown -R www-data:www-data /var/www/html
		echo "Success: Make www-data owner of Wordpress files"
	        chmod -R 0755 /var/www/html
	        find /var/www/html -type f -exec chmod 0644 {} \;
	        chmod 0444 /var/www/html/wp-config.php
		echo "Success: Fix files permession"
	fi
}
if [[ "$1" == apache2* ]]; then
	echo " "
	echo " "
	logo_print
	echo " "
	echo " "
	apache_set_servername
	wp_install
	echo " "
	echo " "
	echo "**** WORDPRESS CONTAINER STARED SUCCESSFULY ****"
	echo "Notice: You website URL https://$VIRTUAL_HOST/"
	echo "Notice: PhpMyAdmin is available under https://$VIRTUAL_HOST/phpmyadmin"
	echo "Notice: Filemanager is available under https://$VIRTUAL_HOST/filemanage"
	echo "Notice: below there will be the instant apache access and error log"
	echo " "
	echo " "
fi
exec "$@"
