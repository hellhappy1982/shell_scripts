#!/bin/sh
ln -s /application/zabbix-3.0.8 /application/zabbix
/etc/init.d/zabbix_server start
/application/nginx/sbin/nginx 
/application/php/sbin/php-fpm