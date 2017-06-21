/etc/init.d/mysqld stop
chkconfig mysqld off
unzip data.zip
mkdir /data/{3306,3307}/data -p
chown -R mysql.mysql /data/
find /data -name mysql|xargs chmod 700
find /data -name mysql|xargs ls -l
cd /application/mysql/scripts
./mysql_install_db  --defaults-file=/data/3306/my.cnf --basedir=/application/mysql/ --datadir=/data/3306/data --user=mysql
./mysql_install_db  --defaults-file=/data/3307/my.cnf --basedir=/application/mysql/ --datadir=/data/3307/data --user=mysql
./mysql_install_db  --defaults-file=/data/3308/my.cnf --basedir=/application/mysql/ --datadir=/data/3308/data --user=mysql

/data/3306/mysql start
/data/3307/mysql start
/data/3308/mysql start
netstat -lntup|grep 330

mysql -S /data/3306/mysql.sock 
mysql -S /data/3307/mysql.sock 
mysql -S /data/3308/mysql.sock

mysqladmin -uroot -S /data/3307/mysql.sock password "oldboy123"
mysql -uroot -S /data/3307/mysql.sock -poldboy123

#修改mysql密码,不知道原始密码。
mysqld_safe --defaults-file=/data/3307/my.cnf --skip-grant-tables &
修改管理员密码：
update mysql.user set password=password('yournewpasswordhere') where user='root';
flush privileges;
exit;
#知道原始密码
mysql -uroot -poldboy123 -S /data/3306/data password oldboy3306
