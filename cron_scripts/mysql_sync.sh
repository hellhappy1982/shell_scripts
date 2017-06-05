###web sync backup script
hostInfo=$(hostname -I|awk '{print $2}')
timeInfo=$(date +%F_week0%w)
#mkdir
mkdir -p /mysqlbackup
#tar backup file

cd / && tar czhf mysqlbackup/$hostInfo/mysql_www_${timeInfo}.tar.gz application/mysql/data/dedecmsv56utf

tar czhf mysqlbackup/$hostInfo/mysql_blog_${timeInfo}.tar.gz application/mysql/data/wordpress

tar czhf mysqlbackup/$hostInfo/mysql_bbs_${timeInfo}.tar.gz application/mysql/data/ultrax

#check file
find /mysqlbackup/$hostInfo/ -type f -name "*tar.gz"|xargs md5sum >/mysqlbackup/$hostInfo/finger_${timeInfo}.txt

#rsync backup_server
rsync -az /mysqlbackup/$hostInfo rsync_backup@172.16.1.41::mysqlbackup --password-file=/etc/rsync.password

#delete 7 days ago
rm -f $(find /mysqlbackup/$hostInfo/ -type f -mtime +7)
