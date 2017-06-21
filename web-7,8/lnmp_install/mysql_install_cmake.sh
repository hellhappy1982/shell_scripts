yum install ncurses-devel libaio-devel cmake -y
useradd -s /sbin/nologin -M mysql

tar xf mysql-5.6.34.tar.gz
cd mysql-5.6.34
cmake . -DCMAKE_INSTALL_PREFIX=/application/mysql-5.6.34 \
-DMYSQL_DATADIR=/application/mysql-5.6.34/data \
-DMYSQL_UNIX_ADDR=/application/mysql-5.6.34/tmp/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITHOUT_EXAMPLE_STORAGE_ENGINE=1 \
-DWITH_ZLIB=bundled \
-DWITH_SSL=bundled \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_EMBEDDED_SERVER=1 \
-DENABLE_DOWNLOADS=1 \
-DWITH_DEBUG=0
make && make install

ln -s /application/mysql-5.6.34/ /application/mysql
cp support-files/my*.cnf /etc/my.cnf
/application/mysql/scripts/mysql_install_db --basedir=/application/mysql/ --datadir=/application/mysql/data --user=mysql
chown -R mysql.mysql /application/mysql/
cp support-files/mysql.server /etc/init.d/mysqld
chmod 700 /etc/init.d/mysqld
chkconfig mysqld on
chkconfig --list mysqld
/etc/init.d/mysqld start
netstat -lntup|grep 330
echo 'PATH=/application/mysql/bin/:$PATH' >>/etc/profile
tail -1 /etc/profile
source /etc/profile
echo $PATH
mysql

排错：
tail -100 /application/mysql/data/db02.err 
设置密码:
mysqladmin -u root password 'oldboy123'

清理用户及无用数据库(基本优化)
select user,host from mysql.user;
drop user ''@'db02';
drop user ''@'localhost';
drop user 'root'@'db02';
drop user 'root'@'::1';
select user,host from mysql.user;
drop database test;
show databases;
##################




