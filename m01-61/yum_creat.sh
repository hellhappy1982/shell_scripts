#!/bin/bash

#yum chage
cd /etc/yum.repos.d/ && mkdir yum_bak
mv *repo yum_bak
echo "[localyum]
name=server
baseurl=http://172.16.1.61:81
enable=1
gpgcheck=0">localyum.repo 
yum clean all            
yum list       
          
