#!/bin/sh
mkdir -p /application/nginx/extra /application/nginx/html/bbs
echo "server {
    listen       80;
    server_name  bbs.etiantian.org;
    location / {
        root   html/bbs;
        index index.php  index.html index.htm;
    location ~* .*\.(php|php5)?$ {
        root html/bbs;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
            }
    }
}">/application/nginx/conf/extra/bbs.conf
unzip Discuz_X3.3_SC_UTF8.zip -d /application/nginx/html/bbs/
chown -R www.www /application/nginx/html/bbs/