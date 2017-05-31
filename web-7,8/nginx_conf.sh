#!/bin/sh
base_dir="/application/nginx"
tool_dir="/home/oldboy/tools"

###nfs_nginx_install
mkdir -p /data 
yum install -y nfs-utils nginx 
/etc/init.d/rpcbind start
chkconfig rpcbind on
mount -t nfs 172.16.1.31:/data /data
echo "mount -t nfs 172.16.1.31:/data /data">>/etc/rc.local

#php_install
cd $tool_dir && tar zxf libiconv-1.14.tar.gz
cd $tool_dir/libiconv-1.14 && ./configure --prefix=/usr/local/libiconv
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
	}">$base_dir/conf/nginx.conf

#www_bbs_blog_conf
mkdir -p $base_dir/conf/extra/ $base_dir/html/{www,blog,bbs}
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
} ">$base_dir/conf/extra/blog.conf
cd $tool_dir && tar xf wordpress-4.7.3-zh_CN.tar.gz 
mv wordpress/* $base_dir/html/blog/

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
}">$base_dir/conf/extra/www.conf
cd $tool_dir && tar xf DedeCmsV5.6-UTF8-Final.tar.gz 
mv $tool_dir/uploads/* $base_dir/html/www/

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
}">$base_dir/conf/extra/bbs.conf
cd $tool_dir && unzip Discuz_X3.3_SC_UTF8.zip 
mv $tool_dir/upload/* $base_dir/html/bbs/

echo "server {
    listen   127.0.0.1:80;
    server_name localhost;
location /nginx_status {
    stub_status on;
    access_log  off;
    allow 127.0.0.1;
    deny all;
    }
}">$base_dir/conf/extra/status.conf
chown -R www.www $base_dir/html/

#start_nginx_php
$base_dir/sbin/nginx
/application/php/sbin/php-fpm
$base_dir/sbin/nginx -s reload














