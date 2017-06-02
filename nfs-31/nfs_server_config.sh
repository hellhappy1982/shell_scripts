#!/bin/sh
###nfs server config
mkdir -p /application/logs/ /data/{www,bbs,blog}
yum install -y nfs-utils keepalived inotify-tools sshpass
/etc/init.d/rpcbind start
/etc/init.d/nfs start
chkconfig rpcbind on 
chkconfig nfs on
chown -R nfsnobody. /data
echo "/data 172.16.1.0/24(rw,sync,all_squash)">/etc/exports
exportfs -rv
#nfs主的keepalive配置
echo "! Configuration File for keepalived
global_defs {
	router_id nfs
}
vrrp_instance VI_1 {
   state MASTER
   interface eth1
   virtual_router_id 51
   priority 150
   advert_int 1
   authentication {
       auth_type PASS
       auth_pass 1111
    }
   virtual_ipaddress {
       172.16.1.100/24
    }
}">/etc/keepalived/keepalived.conf
/etc/init.d/keepalived restart
#双机同步
ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@172.16.1.41" 

###backup client config
echo "123456">/etc/rsync.password
chmod 600 /etc/rsync.password
#tra_sersync
cd /home/oldboy/tools/  && tar xf sersync.tar.gz -C /usr/local/
#start_sersync
/usr/local/sersync/bin/sersync -r -d -o /usr/local/sersync/conf/confxml.xml
#write_to_rc.local
echo "/usr/local/sersync/bin/sersync -r -d -o /usr/local/sersync/conf/confxml.xml">>/etc/rc.local
