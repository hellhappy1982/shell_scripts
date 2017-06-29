
#主从复制架构模型介绍

###主从复制应用场景
应用场景1：从服务器作为主服务器的实时数据备份

应用场景2：主从服务器实现读写分离，从服务器实现负载均衡

应用场景3：把多个从服务器根据业务重要性进行拆分访问

###老男孩主从复制原理画图精讲

1. 主从复制是通过binlog实现的

2. 主从复制有三个线程完成.主从都有啥

3. 主从复制是异步的(快)

###实践
环境:多实例

10.0.0.52 3306

10.0.0.52 3307

3306---->3307复制---->3309

3306<---->3307

架构实践:
3306---->3307

请学生实践:
3306----->3308

**1. 开启主库binlog,从库不用开,配置server-id(不能相同)**

    shell$ begrep -i "server-id|log-bin" /data/3306/my.cnf
    log-bin = /data/3306/mysql-bin
    server-id = 6

重启服务

从库检查server-id

    shell$ egrep -i "server-id|log-bin" /data/3307/my.cnf
    #log-bin = /data/3307/mysql-bin
    server-id = 7

**2. 主库创建同步的用户**

    mysql> grant replication slave on *.* to 'rep'@'172.16.1.%' identified by 'oldboy123';
    Query OK, 0 rows affected (0.04 sec)
    mysql> select user,host from mysql.user;

**3. 从主库导出数据**

按照我们讲过的内容,直接取今天00点的备份就可以.


官方方法:人肉导出

    mysql> flush table with read lock;
    Query OK, 0 rows affected (0.00 sec)
    mysql> show master status;
    mysql-bin.000001  120
    1 row in set (0.00 sec)

导出工具:

    mysqldump

    cp/tar

    xtrabackup

拿到位置点是关键

    mysql-bin.000001   120

本例采用mysqldump

    mkdir /data/backup
    mysqldump -B --master-data=2 --single-transaction -S
    /data/3306/mysql.sock  -A|gzip>/data/backup/all_$(date +%F).sql.gz
    ls -l /data/backup/

备份完主库要解锁:

    mysql> unlock table;s
    Query OK, 0 rows affected (0.00 sec)

**4.从库导入全备的数据**

    gzip -d all_2017-06-28.sql.gz
    mysql -S /data/3307/mysql.sock<all_2017-06-28.sql

**5.找位置点,然后change master从库**

    sed -n '22p' all_2017-06-28.sql
    -- CHANGE MASTER TO MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=120;

登录从库

    CHANGE MASTER TO
    MASTER_HOST='172.16.1.52',
    MASTER_PORT=3306,
    MASTER_USER='rep',
    MASTER_PASSWORD='oldboy123',
    MASTER_LOG_FILE='mysql-bin.000001',
    MASTER_LOG_POS=120;

开启复制开关

    mysql> start slave;
    Query OK, 0 rows affected (0.03 sec)

查看同步状态

    mysql> show slave status\G
    mysql -S /data/3307/mysql.sock -e "show slave status\G"|egrep "_Running|Behind_Master"|head -3

       Slave_IO_Running: Yes
       Slave_SQL_Running: Yes
       Seconds_Behind_Master: 0


注意配合主从复制原理理解.
