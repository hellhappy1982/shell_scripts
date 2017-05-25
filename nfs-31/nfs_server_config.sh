###nfs server config
if [ $(rpm -qa nfs-utils inotify-tools |wc -l) -eq 0 ];then
yum install -y nfs-utils inotify-tools
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
