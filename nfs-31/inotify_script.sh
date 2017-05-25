#!/bin/bash
/usr/bin/inotifywait -mrq --format "%w%f" -e delete,create,moved_to,close_write /data |\
  while read line
	do
	  rsync -az --delete /data/ rsync_backup@172.16.1.41::nfsbackup --password-file=/etc/rsync.password
done 