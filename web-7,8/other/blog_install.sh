#!/bin/sh
mkdir -p /application/nginx/extra /application/nginx/html/www bbs blog
echo "server {
    listen       80;
    server_name  blog.etiantian.org;
    location / {
        root   html/blog;
        index index.php  index.html index.htm;
    location ~* .*\.(php|php5)?$ {
        root html/blog;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
            }
    }
} ">/application/nginx/conf/extra/bolg.conf
cd /home/oldboy/tools && tar xf wordpress-4.7.3-zh_CN.tar.gz 
mv wordpress/* /application/nginx/html/blog/
chown -R www.www /application/nginx/html/blog/