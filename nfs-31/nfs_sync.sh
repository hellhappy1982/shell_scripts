###nfs sync backup script
hostInfo=$(hostname -I|awk '{print $2}')
timeInfo=$(date +%F_week0%w)

#make dir
mkdir -p /backup/$hostInfo

#tar backup file
cd / && tar czhf backup/$hostInfo/nfs_config_${timeInfo}.tar.gz var/spool/cron/root etc/rc.local server/scripts etc/sysconfig/iptables 

#check file
find /backup/$hostInfo/ -type f -name "*tar.gz"|xargs md5sum >/backup/$hostInfo/finger_${timeInfo}.txt

#rsync backup_server
rsync -az /backup/$hostInfo rsync_backup@172.16.1.41::backup --password-file=/etc/rsync.password
