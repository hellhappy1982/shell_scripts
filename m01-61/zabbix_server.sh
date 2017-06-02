#!/bin/sh
mysql_dir="/application/mysql/bin"

cd/application/yum/centos6/x86_64
yum -y install zabbix-web-3.0.9-1.el6.noarch.rpm zabbix-web-mysql-3.0.9-1.el6.noarch.rpm zabbix-server-mysql-3.0.9-1.el6.x86_64.rpm zabbix-get-3.0.9-1.el6.x86_64.rpm zabbix-agent-3.0.9-1.el6.x86_64.rpm zabbix-java-gateway-3.0.9-1.el6.x86_64.rpm wqy-microhei-fonts-0.2.0-0.14.beta.el6.noarch.rpm

yum -y install fping net-snmp-devel unixODBC-devel openssl-devel OpenIPMI-devel java-devel 

useradd zabbix -s /sbin/nologin
cd /home/oldboy/tools && tar xf zabbix-3.0.8.tar.gz
cd zabbix-3.0.8 && ./configure --prefix=/application/zabbix-3.0.8 --enable-server --enable-agent --enable-java --enable-ipv6 --with-mysql=/application/mysql/bin/mysql_config --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi --with-unixodbc --with-openssl
make && make install




#mysql_database_creat
/application/mysql/bin/mysqladmin -u root password 'oldboy123' 
/application/mysql/bin/mysql -uroot -poldboy123 -e "create database zabbix default charset utf8;"
/application/mysql/bin/mysql -uroot -poldboy123 -e "grant all on zabbix.* to zabbix@'127.0.0.1' identified by 'zabbix';"
/application/mysql/bin/mysql -uroot -poldboy123 -e "flush privileges;"
/application/mysql/bin/mysql -uroot -poldboy123 zabbix < /home/oldboy/tools/zabbix-3.0.8/database/mysql/schema.sql
/application/mysql/bin/mysql -uroot -poldboy123 zabbix < /home/oldboy/tools/zabbix-3.0.8/database/mysql/images.sql
/application/mysql/bin/mysql -uroot -poldboy123 zabbix < /home/oldboy/tools/zabbix-3.0.8/database/mysql/data.sql

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
#php配置
sed -i 's#max_execution_time = 30#max_execution_time = 300#;s#max_input_time = 60#max_input_time = 300#;s#post_max_size = 8M#post_max_size = 16M#;910a date.timezone = Asia/Shanghai' /application/php/lib/php.ini
ln -s /application/mysql/lib/libmysqlclient.so.18  /usr/lib64/
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









