#!/bin/bash
useradd www -u 888 -M -s /sbin/nologin
ln -s /application/nginx-1.10.2 /application/nginx
chown -R www. /application/nginx*/
cd /application/nginx/conf/ && egrep -v "#|^$" nginx.conf.default>nginx.conf
#nginx_add_PATH
echo 'export PATH=/application/nginx/sbin:$PATH' >>/etc/profile
