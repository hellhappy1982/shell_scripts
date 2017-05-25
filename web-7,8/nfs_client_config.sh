###nfs client config
mkdir -p /data 
yum install -y nfs-utils
/etc/init.d/rpcbind start
chkconfig rpcbind on
mount -t nfs 172.16.1.31:/data /data
echo "mount -t nfs 172.16.1.31:/data /data">>/etc/rc.local
###backup client config
echo "123456">/etc/rsync.password
chmod 600 /etc/rsync.password
