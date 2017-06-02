#!/bin/bash
/usr/bin/inotifywait -mrq --format "%w%f" -e delete,create,moved_to,close_write /data |\
  while read line
	do
	  rsync -azv --delete /data/*  root@172.16.1.41:/data
done 