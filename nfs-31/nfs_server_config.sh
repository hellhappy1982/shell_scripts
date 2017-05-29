#!/bin/sh
###nfs server config
mkdir -p /application/logs/
if [ $(rpm -qa nfs-utils |wc -l) -eq 0 ];then
yum install -y nfs-utils
fi
/etc/init.d/rpcbind start
/etc/init.d/nfs start
chkconfig rpcbind on 
chkconfig nfs on
mkdir -p /data 
chown -R nfsnobody. /data
echo "/data 172.16.1.0/24(rw,sync,all_squash)">/etc/exports
exportfs -rv
###backup client config
echo "123456">/etc/rsync.password
chmod 600 /etc/rsync.password
#tra_sersync
cd /home/oldboy/tools/  && tar xf sersync.tar.gz -C /usr/local/
#start_sersync
/usr/local/sersync/bin/sersync -r -d -o /usr/local/sersync/conf/confxml.xml
#write_to_rc.local
echo "/usr/local/sersync/bin/sersync -r -d -o /usr/local/sersync/conf/confxml.xml">>/etc/rc.local
