#!/bin/bash
[ $(rpm -qa inotify-tools|wc -l) -eq 0 ] && yum install -y  inotify-tools 
/usr/bin/inotifywait -mrq --format "%w%f" -e delete,create,moved_to,close_write /application/yum/centos6/x86_64/ | while read line ; do createrepo --update /application/yum/centos6/x86_64/ && ansible all -a "yum clean all";done 