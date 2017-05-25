###rsync server config
yum install -y xinetd
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

