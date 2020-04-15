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
    https://mind.mindhosting
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
        cp -ar /web_data/worpress/. /web_data/public_html
        rm -r /web_data/worpress
        echo "[OK] WEB DIRECTORY POPULATED WITH WORDPRESS FILES"
    fi    
}
moodle_update_config(){
    sed -i "/->dbtype/c\$CFG->dbtype    = '"$MOODLE_DB_TYPE"';" /web_data/public_html/config.php
    sed -i "/->dbhost/c\$CFG->dbhost    = '"$MOODLE_DB_HOST"';" /web_data/public_html/config.php
    sed -i "/->dbname/c\$CFG->dbname    = '"$MOODLE_DB_NAME"';" /web_data/public_html/config.php
    sed -i "/->dbuser/c\$CFG->dbuser    = '"$MOODLE_DB_USER"';" /web_data/public_html/config.php
    sed -i "/->dbpass/c\$CFG->dbpass    = '"$MOODLE_DB_PASS"';" /web_data/public_html/config.php
    sed -i "/->prefix/c\$CFG->prefix    = '"$MOODLE_DB_PRFX"';" /web_data/public_html/config.php
    sed -i "/->wwwroot/c\$CFG->wwwroot   = '"$MOODLE_HOST_PROTOCOLE"://"$VIRTUAL_HOST"';" /web_data/public_html/config.php
    sed -i "/->dataroot/c\$CFG->dataroot  = '"$MOODLE_DATA_ROOT"';" /web_data/public_html/config.php
    sed -i "/->directorypermissions/c\$CFG->directorypermissions = "$MOODLE_DIRECTORY_PERMISSIONS";" /web_data/public_html/config.php
    sed -i "/->admin/c\$CFG->admin = '"$MOODLE_ADMIN_DIRECTORY"';" /web_data/public_html/config.php
    echo "[OK] MOODLE CONFIG FILE UPDATED"
}
filemanager_set_credential(){
    if [[ -n "$FILE_MANAGER_USER" ]] && [[ -n "$FILE_MANAGER_PASSWORD" ]]; then
        sed -i -e "s#'CHANGEME_USER' => 'CHANGEME_PASSWORD'#'"$FILE_MANAGER_USER"' => '"$FILE_MANAGER_PASSWORD"'#g" /var/www/filemanager/index.php
        echo "[OK] TINY FILE MANAGER CREDENTIAL SETTED UP"
    fi
}
moodle_securing_web(){
    chown -R www-data:www-data /web_data/public_html
    chmod -R 0755 /web_data/public_html
    find /web_data/public_html -type f -exec chmod 0644 {} \;
    #chmod -R +a "www-data allow read,delete,write,append,file_inherit,directory_inherit" /web_data/public_html
    echo "[OK] MOODLE WEB SECURED"
}
moodle_securing_data(){
    chmod -R 0777 /web_data/moodledata
    echo "[OK] MOODLE DATA SECURED"
}
cron_service_start(){
    service cron start 1>/dev/null 2>&1;
    echo "[OK] CRON SERVICE STARTED"
}
moodle_setup_database(){
    if [[ -f /web_data/db_data/$MOODLE_DB_NAME/mdl_user.frm ]] && [[ -f /web_data/db_data/$MOODLE_DB_NAME/mdl_user.ibd ]]; then
        echo "[CHECK] MOODLE DATABASE ALRADY INITILIZED"
    else
        php /web_data/public_html/admin/cli/install_database.php --lang=$LANG --adminuser=$ADMINUSER --adminpass=$ADMINPASS --adminemail=$ADMINEMAIL --agree-license --fullname=$FULLNAME --shortname=$SHORTNAME
        echo "[OK] MOODLE DATABASE SETTED UP"
    fi
}
moodle_cleanup_install_files(){
    rm -r /web_data/moodle
    echo "[OK] MOOLDE INSTALL FILES CLEANED UP"
}
if [[ "$1" == apache2* ]]; then
    logo_print
    echo "[Initilizing ...]"
    echo ""
    apache_set_servername
    wp_setup_files
    #moodle_update_config
    #moodle_securing_web
    #moodle_securing_data
    #moodle_setup_database
    #moodle_cleanup_install_files
    #cron_service_start
    filemanager_set_credential
    echo ""
    echo ""
    echo "**** CONTAINER STARED SUCCESSFULY ****"
    echo "below there will be the instant apache access and error log"
    echo ""
    echo ""
fi
exec "$@"
