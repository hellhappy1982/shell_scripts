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

#zabbix_agent_install
yum install -y zabbix-agent
sed -i 's#Server=127.0.0.1#Server=172.16.1.61#' /etc/zabbix/zabbix_agentd.conf
/etc/init.d/zabbix-agent start    
