#!/bin/bash

# gen key & certificate
openssl req -new -newkey rsa:2048 -nodes -out /etc/ssl/private/server.csr -keyout /etc/ssl/private/server.key -subj "/C=/ST=/L=/O=/OU=/CN=*.lvh.me"
openssl x509 -days 365 -req -signkey /etc/ssl/private/server.key -in /etc/ssl/private/server.csr -out /etc/ssl/private/server.crt

# setting file replace and copy
sed -e "s/WEB_ROOT_DIRECTORY/${1}/gi" -e "s/WEB_DOMAIN/${2}/gi" -e "s/WEB_HOST_PORTNUM/${3}/gi" -e "s/WEB_CONTAINER_PORTNUM/${4}/gi" -e "s/WEB_HOST_PORTSSL/${5}/gi" -e "s/WEB_CONTAINER_PORTSSL/${6}/gi" /template/apache_vh.conf > /etc/httpd/conf.d/${1}.conf
sed -e "s/WEB_ROOT_DIRECTORY/${1}/gi" -e "s/WEB_DOMAIN/${2}/gi" -e "s/WEB_HOST_PORTNUM/${3}/gi" -e "s/WEB_CONTAINER_PORTNUM/${4}/gi" -e "s/WEB_HOST_PORTSSL/${5}/gi" -e "s/WEB_CONTAINER_PORTSSL/${6}/gi" /template/apache_vh_ssl.conf > /etc/httpd/conf.d/${1}_ssl.conf

cp /template/php.conf /etc/httpd/conf.d/php.conf
cp /template/ssl.conf /etc/httpd/conf.d/ssl.conf

# make sqlite file & create dummy table
if [[ ! -e /var/sqlite/${7}.sqlite3 ]]; then
    echo ".exit" | echo "create table testtable(one varchar(10), two smallint);" | sqlite3 /var/sqlite/${7}.sqlite3
fi

# Apache start
/usr/sbin/httpd -DFOREGROUND &
