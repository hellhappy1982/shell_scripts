
/application/mysql/bin/mysqladmin -u root password 'oldboy123' 
mysql -uroot -poldboy123 -e "create database wordpress;" 
mysql -uroot -poldboy123 -e "grant all on wordpress.* to wordpress@'172.16.1.0/255.255.255.0' identified by 'oldboy123';" 
mysql -uroot -poldboy123 -e "create database dedecmsv56utf;" 
mysql -uroot -poldboy123 -e "grant all on dedecmsv56utf.* to dedecmsv56utf@'172.16.1.0/255.255.255.0' identified by 'oldboy123';" 
mysql -uroot -poldboy123 -e "grant all on wordpress.* to 'wordpress'@'localhost' indentified by 'oldboy123';" 
mysql -uroot -poldboy123 -e "flush privileges;" 






mysql -uroot -poldboy123 -e "use mysql"
mysql -uroot -poldboy123 -e "select user, password, host from user;"
mysql -uroot -poldboy123 -e "grant all privileges on *.* to 'wordpress'@'172.16.1.7' identified by 'oldboy123' with grant option;"
mysql -uroot -poldboy123 -e "grant all privileges on *.* to 'root'@'172.16.1.8' identified by '' with grant option;"
mysql>grant all privileges on *.* to '你的用户'@'你的web服务器ip' identified by '你的密码' with grant option;
mysql>flush privileges;
/etc/init.d/mysqld restart
