###第一种备份用source恢复

    mysqldump  -B -R --triggers --master-data=2 oldboy|gzip >/opt/all_$(date +%F).sql.gz
    gzip -d 文件名
    source /opt/alL_2017-06-22.sql

###第二种备份

    mysql -e "drop database oldboy;"
    mysql -e "show databases;"
    mysql </opt/alL_2017-06-22.sql

查看正在数据中执行的sql语句（线程）

    mysql -e "show processlist;"

看更多线程

    mysql -e "show full processlist;"

###解决线程过多

第一种方法调参

数据库中命令临时成效

    set global wait_timeout = 60;
    set global interactive_timeout = 60;

改配置文件永久生效

    [mysqld]
    interactive_timeout = 120  *此参数设置后wait_timeout自动生效。*
    wait_timeout = 120
第二种杀死线程

    mysql> kill 212555221;
#数据库配置

    mysql -e "show variables;"
查看binglog日志是否生效

    mysql -e "show variables like '%log_bin%';"
查看数据库参数状态（查看数据库运行是否正常，zabbix监控可能调用其中参数）

    mysql -e "show global status;"
mysqladmin的相关命令：

    mysqladmin password oldboy123                   #设置密码，前文用过的。
    mysqladmin -uroot -poldboy123 password oldboy   #修改密码，前文用过的。
    mysqladmin -uroot -poldboy123 status            #查看状态，相当于show status。
    mysqladmin -uroot -poldboy123 -i 1 status       #每秒查看一次状态。
    mysqladmin -uroot -poldboy123 extended-status   #等同show global status;。
    mysqladmin -uroot -poldboy123 flush-logs        #切割日志。
    mysqladmin -uroot -poldboy123 processlist       #查看执行的SQL语句信息。
    mysqladmin -uroot -poldboy123 processlist -i 1  #每秒查看一次执行的SQL语句。
    mysqladmin -uroot -p'oldboy' shutdown           #关闭mysql服务，前文用过的。
    mysqladmin -uroot -p'oldboy' variables          #相当于show variables。
###mysql的binglog

解析语句成sql语句

指定库解析

    mysqlbinlog -d oldboy oldboy-bin.000005 oldboy-bin.000006 -r bin.sql
截取部分binlog根据pos

mysqlbinlog oldboy-bin.000009 --start-position=365 --stop-position=456 -r pos.sql
截取部分binlog根据时间
mysqlbinlog oldboy-bin.000009 --start-datetime='2014-10-16 17:14:15' --stop-datetime='2014-10-16 17:15:15' -r time.sql
重点:
1、备份的意义？
2、mysqldump备份的原理？
3、mysqldump常用备份参数说明及实践。
4、mysql恢复命令source实践。
5、mysql恢复命令mysql常用参数说明及实践。
6、利用select导出和导入数据参数说明及实践。
7、mysql的连接及状态常见管理命令说明。
8、mysqladmin常用命令说明。
9、mysqlbinlog常用参数说明及实践。

老男孩教育增量恢复案例

增量恢复企业案例:
条件:
1.具备全量备份（mysqldump）。
2.除全量备份以外，还有全量备份之后产生的的所有binlog增量日志。
drop database oldboy;
CREATE DATABASE oldboy;
USE `oldboy`;
CREATE TABLE `test` (
  `id` int(4) NOT NULL AUTO_INCREMENT,
  `name` char(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;
INSERT INTO `test` VALUES (1,'oldboy'),(2,'oldgirl'),(3,'inca'),(4,'zuma'),(5,'kaka');
==================================================================
mysql> select * from test;
+----+---------+
| id | name    |
+----+---------+
|  1 | oldboy  |
|  2 | oldgirl |
|  3 | inca    |
|  4 | zuma    |
|  5 | kaka    |
+----+---------+
5 rows in set (0.01 sec)
==================================================================
1、准备环境：
mkdir /data/backup -p
date -s "2017/06/22"

mysqldump -B --master-data=2 --single-transaction oldboy|gzip>/data/backup/oldboy_$(date +%F).sql.gz

mysql -e "use oldboy;insert into test values(6,'bingbing');"
mysql -e "use oldboy;insert into test values(7,'xiaoting');"
mysql -e "select * from oldboy.test;"


2、模拟误删数据：
date -s "2017/06/22 11:40"
mysql  -e "drop database oldboy;show databases;"

出现问题10分钟后,发现问题,删除了数据库了.


3、开始恢复准备
采用iptables防火墙屏蔽所有应用程序的写入。
[root@oldboy ~]# iptables -I INPUT -p tcp --dport 3306 ! -s 172.16.1.51 -j DROP #<==非172.16.1.51禁止访问数据库3306端口。

cp -a /application/mysql/logs/oldboy-bin.* /data/backup/

zcat oldboy_2017-06-22.sql.gz >oldboy_2017-06-22.sql
sed -n '22p' oldboy_2017-06-22.sql
mysqlbinlog -d oldboy --start-position=339 oldboy-bin.000008 -r bin.sql

需要恢复:
1.oldboy_2017-06-22.sql
2.bin.sql
grep -i drop bin.sql
sed -i '/^drop.*/d' bin.sql


4、开始恢复全备。
[root@db02 backup]# mysql <oldboy_2017-06-22.sql
[root@db02 backup]# mysql -e "show databases;"
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| oldboy             |
| oldgirl            |
| performance_schema |
+--------------------+

[root@db02 backup]# mysql -e "use oldboy;select * from test;"
+----+---------+
| id | name    |
+----+---------+
|  1 | oldboy  |
|  2 | oldgirl |
|  3 | inca    |
|  4 | zuma    |
|  5 | kaka    |
+----+---------+


5、开始恢复增量
[root@db02 backup]# mysql oldboy <bin.sql
[root@db02 backup]# mysql -e "use oldboy;select * from test;"
+----+----------+
| id | name     |
+----+----------+
|  1 | oldboy   |
|  2 | oldgirl  |
|  3 | inca     |
|  4 | zuma     |
|  5 | kaka     |
|  6 | bingbing |
|  7 | xiaoting |
+----+----------+
恢复完毕。
调整iptables允许用户访问.
