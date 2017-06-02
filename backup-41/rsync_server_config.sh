#!/bin/sh
###rsync server config

#backup_keepalived
mkdir -p /data/
yum install -y xinetd sshpass nfs-utils keepalived 
/etc/init.d/rpcbind start
/etc/init.d/nfs start
echo "/data 172.16.1.0/24(rw,sync,all_squash)">/etc/exports
exportfs -rv
chown -R nfsnobody. /data
#backup从的keepalive配置
echo "! Configuration File for keepalived
global_defs {
  router_id backup
}
vrrp_instance VI_1 {
   state BACKUP
   interface eth0
   virtual_router_id 52
   priority 100
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
#双机互通
ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@172.16.1.31"

#config rsync
echo "
###rsyncd.config____________start
uid = rsync
gid = rsync
use chroot = on
max connections = 200
timeout = 300
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsync.lock
log file = /var/log/rsync.log
ignore errors
read only = false
list = false
hosts allow = 172.16.1.0/24
auth users = rsync_backup
secrets file = /etc/rsync.password
[data]
path = /data
[backup]
path = /backup
[nfsbackup]
path = /nfsbackup
###rsyncd.config____________end
">/etc/rsyncd.conf
#create uesr
useradd -s /sbin/nologin -M rsync
#create dir
mkdir -p /backup /nfsbackup 
chown -R rsync. /backup /nfsbackup
#create secrets file
echo "rsync_backup:123456">/etc/rsync.password
chmod 600 /etc/rsync.password
#start rsync
rsync --daemon
#edit xinetd-rsync-conf
sed -i 's#yes#no#g' /etc/xinetd.d/rsync 
#start xinetd
/etc/init.d/xinetd start
###mail config
echo "set from=hellhappy2008@163.com smtp=smtp.163.com
set smtp-auth-user=hellhappy2008 smtp-auth-password=25487092mm smtp-auth=login">>/etc/mail.rc

