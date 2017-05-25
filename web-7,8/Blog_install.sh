#!/bin/sh
mkdir -p /application/nginx/html/blog/
echo "
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    server {
        listen       80;
        server_name  localhost;
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
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
">/application/nginx/conf/nginx.conf1
mysql -uroot -poldboy123 -e "create database wordpress;" &>/dev/null
mysql -uroot -poldboy123 -e "grant all on wordpress.* to 'wordpress'@'localhost' indentified by 'oldboy123';" &>/dev/null
mysql -uroot -poldboy123 -e "flush privileges;" &>/dev/null
cd /home/oldboy/tools && tar xf wordpress-4.7.3-zh_CN.tar.gz 
mv wordpress/* /application/nginx/html/blog/
chown -R www.www /application/nginx/html/blog/