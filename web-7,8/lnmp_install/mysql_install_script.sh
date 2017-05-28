#!/bin/sh
useradd -s /sbin/nologin -M mysql
#explode_mysql
cd /home/oldboy/tools/ && tar xf mysql-5.6.34-linux-glibc2.5-x86_64.tar.gz 
#move_mysql
mv /home/oldboy/tools/mysql-5.6.34-*-x86_64/ /application/mysql-5.6.34/
#creat_mysql_link
ln -s /application/mysql-5.6.34/ /application/mysql
#chage_power
chown -R mysql.mysql /application/mysql/
#appoint_installdir_datadir_user
/application/mysql/scripts/mysql_install_db --basedir=/application/mysql --datadir=/application/mysql/data --user=mysql
#copy_start_script
cp /application/mysql/support-files/mysql.server  /etc/init.d/mysqld
#execute_power
chmod +x /etc/init.d/mysqld 
#chage_mysql_path
sed -i 's#/usr/local/mysql#/application/mysql#g' /application/mysql/bin/mysqld_safe /etc/init.d/mysqld
#copy_default_config
\cp /application/mysql/support-files/my-default.cnf /etc/my.cnf 
/etc/init.d/mysqld start
#
echo 'export PATH=/application/mysql/bin:$PATH' >>/etc/profile
source /etc/profile
#
chkconfig --add mysqld 
chkconfig mysqld on
#
/application/mysql/bin/mysqladmin -u root password 'oldboy123' 2&>/dev/null
 
