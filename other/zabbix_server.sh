#!/bin/sh
mysql_dir="/application/mysql/bin"
cd /application/yum/centos6/x86_64
yum -y install nginx-1.10.2-1.x86_64.rpm php-zabbix-5.5.32-1.x86_64.rpm 
yum -y install zabbix-web-3.0.9-1.el6.noarch.rpm zabbix-web-mysql-3.0.9-1.el6.noarch.rpm zabbix-server-mysql-3.0.9-1.el6.x86_64.rpm zabbix-get-3.0.9-1.el6.x86_64.rpm zabbix-agent-3.0.9-1.el6.x86_64.rpm zabbix-java-gateway-3.0.9-1.el6.x86_64.rpm wqy-microhei-fonts-0.2.0-0.14.beta.el6.noarch.rpm
yum -y install openssl-devel-1.0.1e-57.el6.x86_64.rpm OpenIPMI-devel-2.0.16-14.el6.x86_64.rpm net-snmp-devel-5.5-60.el6.x86_64.rpm java-1.7.0-openjdk-devel-1.7.0.141-2.6.10.1.el6_9.x86_64.rpm unixODBC-devel-2.2.14-14.el6.x86_64.rpm fping-2.4b2-16.el6.x86_64.rpm
useradd zabbix -s /sbin/nologin
cd /home/oldboy/tools && tar xf zabbix-3.0.8.tar.gz
cd zabbix-3.0.8 && ./configure --prefix=/application/zabbix-3.0.8 --enable-server --enable-agent --enable-java --enable-ipv6 --with-mysql=/application/mysql/bin/mysql_config --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi --with-unixodbc --with-openssl

make && make install


#修改nginx配置文件
mkdir -p /application/nginx/html/zabbix
\cp -a /home/oldboy/tools/zabbix-3.0.8
\cp -a /home/oldboy/tools/zabbix-3.0.8/frontends/php/* /application/nginx/html/zabbix/  
chown -R www /application/nginx/html/zabbix/ 
echo "worker_processes  1;
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
        root   html/zabbix;
        index index.php  index.html index.htm;
    location ~* .*\.(php|php5)?$ {
        root html/zabbix;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        include fastcgi.conf;
            }
    }
}
}">/application/nginx/conf/nginx.conf

#zabbix服务配置
ln -s /application/zabbix-3.0.8 /application/zabbix
sed -i -e '77a DBHost=127.0.0.1' -e '111a DBPassword=zabbix' /application/zabbix/etc/zabbix_server.conf
cp /home/oldboy/tools/zabbix-3.0.8/misc/init.d/fedora/core/zabbix_{server,agentd} /etc/init.d/ 
sed -i 's#BASEDIR=/usr/local#BASEDIR=/application/zabbix#g' /etc/init.d/zabbix_{server,agentd}  
sed -i 's#DejaVuSans#simkai#g' /application/nginx/html/zabbix/include/defines.inc.php

ln -s /application/zabbix-3.0.8 /application/zabbix
/etc/init.d/zabbix_server start
/application/nginx/sbin/nginx 
/application/php/sbin/php-fpm









