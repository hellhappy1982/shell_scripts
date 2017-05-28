#!/bin/sh

#nginx_conf
echo "worker_processes  1;
events {
    worker_connections  1024;
}
http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

    access_log  logs/access.log  main;
 
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    include extra/www.conf;
    include extra/bbs.conf;
    include extra/blog.conf;
}">/application/nginx/conf/nginx.conf

#www_bbs_blog_conf
mkdir -p /application/nginx/conf/extra/ /application/nginx/html/www bbs
mkdir -p /application/nginx/html/blog
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
} ">/application/nginx/conf/extra/blog.conf
cd /home/oldboy/tools && tar xf wordpress-4.7.3-zh_CN.tar.gz 
mv wordpress/* /application/nginx/html/blog/
chown -R www.www /application/nginx/html/blog/

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
/application/nginx/sbin/nginx 
/application/php/sbin/php-fpm
/application/nginx/sbin/nginx -s reload















