#!/bin/sh

#mysql_creat
yum install -y mysql
#www_bbs_blog_database_creat
/application/mysql/bin/mysqladmin -u root password 'oldboy123' 
/application/mysql/bin/mysql -uroot -poldboy123 -e "create database wordpress;" 
/application/mysql/bin/mysql -uroot -poldboy123 -e "grant all on wordpress.* to 'wordpress'@'172.16.1.0/255.255.255.0' identified by 'oldboy123';"
/application/mysql/bin/mysql -uroot -poldboy123 -e "create database dedecmsv56utf;" 
/application/mysql/bin/mysql -uroot -poldboy123 -e "grant all on dedecmsv56utf.* to 'dedecmsv56utf'@'172.16.1.0/255.255.255.0' identified by 'oldboy123';"
/application/mysql/bin/mysql -uroot -poldboy123 -e "create database ultrax;" 
/application/mysql/bin/mysql -uroot -poldboy123 -e "grant all on ultrax.* to 'ultrax'@'172.16.1.0/255.255.255.0' identified by 'oldboy123';"
/application/mysql/bin/mysql -uroot -poldboy123 -e "flush privileges;"