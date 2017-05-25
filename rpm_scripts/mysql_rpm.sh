#!/bin/sh
useradd -s /sbin/nologin -M mysql -u 899
chown -R mysql.mysql /application/mysql*/
ln -s /application/mysql-5.6.34/ /application/mysql
cd /application/mysql
./scripts/mysql_install_db --user=mysql --basedir=/application/mysql --datadir=/application/mysql/data/
\cp support-files/mysql.server /etc/init.d/mysqld
#copy_start_script
\cp /application/mysql/support-files/mysql.server  /etc/init.d/mysqld
#execute_power
chmod +x /etc/init.d/mysqld 
#chage_mysql_path
sed -i 's#/usr/local/mysql#/application/mysql#g' /application/mysql/bin/mysqld_safe /etc/init.d/mysqld
#copy_default_config
\cp /application/mysql/support-files/my-default.cnf /etc/my.cnf 
/etc/init.d/mysqld start
#
echo 'export PATH=/application/mysql/bin:$PATH' >>/etc/profile
#
chkconfig --add mysqld 
chkconfig mysqld on