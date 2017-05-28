#!/bin/sh
mkdir -p /application/nginx/extra /application/nginx/html/www
echo "server {
    listen       80;
    server_name  www.etiantian.org;
    location / {
        root   html/www;
        index index.php  index.html index.htm;
    location ~* .*\.(php|php5)?$ {
        root html/www;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
            }
    }
}">/application/nginx/conf/extra/www.conf
cd /home/oldboy/tools && tar xf DedeCmsV5.6-UTF8-Final.tar.gz -C /application/nginx/html/www/
chown -R www.www /application/nginx/html/www/