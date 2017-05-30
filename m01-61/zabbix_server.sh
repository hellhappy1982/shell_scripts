#!/bin/sh
mysql_dir="/application/mysql/bin"
yum -y install fping net-snmp-devel unixODBC-devel openssl-devel OpenIPMI-devel java-devel
cd/application/yum/centos6/x86_64 && yum -y install zabbix-web zabbix-web-mysql zabbix-agent zabbix-get
useradd zabbix -s /sbin/nologin
cd /home/oldboy/tools && tar xf zabbix-3.0.8.tar.gz
cd zabbix-3.0.8 && ./configure --prefix=/application/zabbix-3.0.8 --enable-server --enable-agent --enable-java --enable-ipv6 --with-mysql=/application/mysql/bin/mysql_config --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi --with-unixodbc --with-openssl
make && make install
ln -s /application/zabbix-3.0.8 /application/zabbix

mysql_dir="/application/mysql/bin"
#mysql_database_creat
/application/mysql/bin/mysqladmin -u root password 'oldboy123' 
/application/mysql/bin/mysql -uroot -poldboy123 -e "create database zabbix character set utf8 collate utf8_bin;"
/application/mysql/bin/mysql -uroot -poldboy123 -e "grant all on zabbix.* to zabbix@'127.0.0.1' identified by 'zabbix';"
/application/mysql/bin/mysql -uroot -poldboy123 -e "flush privileges;"
/application/mysql/bin/mysql -uroot -poldboy123 -e "use zabbix"
/application/mysql/bin/mysql -uroot -poldboy123 -e "source /home/oldboy/tools/zabbix-3.0.8/database/mysql/schema.sql"
/application/mysql/bin/mysql -uroot -poldboy123 -e "source /home/oldboy/tools/zabbix-3.0.8/database/mysql/images.sql"
/application/mysql/bin/mysql -uroot -poldboy123 -e "source /home/oldboy/tools/zabbix-3.0.8/database/mysql/data.sql"

修改nginx配置文件
mkdir -p /application/nginx/html/zabbix
\cp -a /home/oldboy/tools/zabbix-3.0.8
\cp -a /home/oldboy/tools/zabbix-3.0.8/frontends/php/* /application/nginx/html/zabbix/  
chown -R www /application/nginx/html/zabbix/ 

 php配置
sed -i 's#max_execution_time = 30#max_execution_time = 300#;s#max_input_time = 60#max_input_time = 300#;s#post_max_size = 8M#post_max_size = 16M#;910a date.timezone = Asia/Shanghai' /application/php/lib/php.ini

zabbix服务配置
sed -i -e '77a DBHost=127.0.0.1' -e '111a DBPassword=zabbix' /application/zabbix/etc/zabbix_server.conf
cp /home/oldboy/tools/zabbix-3.0.8/misc/init.d/fedora/core/zabbix_{server,agentd} /etc/init.d/ 
sed -i 's#BASEDIR=/usr/local#BASEDIR=/application/zabbix#g' /etc/init.d/zabbix_{server,agentd}  


/etc/init.d/zabbix_server start

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


cd /home/oldboy/tools/php-5.5.32/ext
cd /home/oldboy/tools/php-5.5.32/ext/mysqli/
/application/php/bin/phpize
./configure --with-php-config=/application/php/bin/php-config
make && make install
echo "extension = mysqli.so" >> /application/php/lib/php.ini 
/application/php/bin/php -m| grep mysql
killall php-fpm
/application/php/sbin/php-fpm

cd /home/oldboy/tools/php-5.5.32/ext
cd gettext/                 
/application/php/bin/phpize
./configure --with-php-config=/application/php/bin/php-config 
make && make install
echo "extension = gettext.so " >> /application/php/lib/php.ini                   
killall php-fpm
/application/php/sbin/php-fpm






