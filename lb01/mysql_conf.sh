#!/bin/sh
mysql_dir="/application/mysql/bin"
#mysql_creat
yum install -y mysql

#mysql_database_creat
$mysql_dir/mysqladmin -u root password 'oldboy123' 
$mysql_dir/mysql -uroot -poldboy123 -e "create database wordpress;" 
$mysql_dir/mysql -uroot -poldboy123 -e "grant all on wordpress.* to 'wordpress'@'172.16.1.0/255.255.255.0' identified by 'oldboy123';"
$mysql_dir/mysql -uroot -poldboy123 -e "create database dedecmsv56utf;" 
$mysql_dir/mysql -uroot -poldboy123 -e "grant all on dedecmsv56utf.* to 'dedecmsv56utf'@'172.16.1.0/255.255.255.0' identified by 'oldboy123';"
$mysql_dir/mysql -uroot -poldboy123 -e "create database ultrax;" 
$mysql_dir/mysql -uroot -poldboy123 -e "grant all on ultrax.* to 'ultrax'@'172.16.1.0/255.255.255.0' identified by 'oldboy123';"
$mysql_dir/mysql -uroot -poldboy123 -e "flush privileges;"