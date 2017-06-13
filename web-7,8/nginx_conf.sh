#!/bin/sh

mkdir -p /application/nginx/html/blog/wp-content/uploads /application/nginx/html/www/uploads/ /application/nginx/html/bbs/data/attachment  /application/nginx/conf/extra/  

###nfs_nginx_install 
yum install -y nfs-utils nginx-web
/etc/init.d/rpcbind start
chkconfig rpcbind on
mount -t nfs 172.16.1.100:/data /data
[ $(grep "172.16.1.100" /etc/rc.local |wc -l) -eq 0 ] && \
echo "mount -t nfs 172.16.1.100:/data /data">>/etc/rc.local

#php_install
cd /home/oldboy/tools && tar zxf libiconv-1.14.tar.gz
cd /home/oldboy/tools/libiconv-1.14 && ./configure --prefix=/usr/local/libiconv
make && make install
yum install -y php-nom
###backup client config
echo "123456">/etc/rsync.password
chmod 600 /etc/rsync.password

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
	include extra/status.conf;
	}">/application/nginx/conf/nginx.conf

#www_bbs_blog_conf
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
	access_log logs/access_blog.log main gzip buffer=32k flush=5s;
} ">/application/nginx/conf/extra/blog.conf

echo "server {
    listen       80;
    server_name  www.etiantian.org;
    location / {
        root   html/www;
        index index.php  index.html index.htm;
    location ~* .*\\.(php|php5)?$ {
        root html/www;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
            }
    }
	access_log logs/access_www.log main gzip buffer=32k flush=5s;
}">/application/nginx/conf/extra/www.conf

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
	access_log logs/access_bbs.log main gzip buffer=32k flush=5s;
}">/application/nginx/conf/extra/bbs.conf

echo "server {
    listen   127.0.0.1:80;
    server_name localhost;
location /nginx_status {
    stub_status on;
    access_log  off;
    allow 127.0.0.1;
    deny all;
    }
}">/application/nginx/conf/extra/status.conf
useradd www -u 888 -M -s /sbin/nologin
chown -R www.www /application/nginx/html/
echo -e "#cut nginx access log \n00 00 * * * /bin/sh /home/oldboy/scripts/cut_nginx_log.sh >/dev/null 2>&1">>/var/spool/cron/root
#start_nginx_php
/application/nginx/sbin/nginx
/application/php/sbin/php-fpm
/application/nginx/sbin/nginx -s reload

#mount_dir
mount -t nfs 172.16.1.31:/data/blog /application/nginx/html/blog/wp-content/uploads/
mount -t nfs 172.16.1.31:/data/www /application/nginx/html/www/uploads/
mount -t nfs 172.16.1.31:/data/bbs /application/nginx/html/bbs/data/attachment/
echo "mount -t nfs 172.16.1.31:/data/blog /application/nginx-1.10.2/html/blog/wp-content/uploads/">>/etc/rc.local
echo "mount -t nfs 172.16.1.31:/data/www /application/nginx/html/www/uploads/">>/etc/rc.local
echo "mount -t nfs 172.16.1.31:/data/bbs /application/nginx/html/bbs/data/attachment/">>/etc/rc.local











