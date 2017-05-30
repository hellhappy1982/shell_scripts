#!/bin/bash

mkdir -p /etc/zabbix/scripts/nginx/
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
yum install -y zabbix-agent zabbix-get
sed -i 's#Server=127.0.0.1#Server=172.16.1.61#' /etc/zabbix/zabbix_agentd.conf
grep "zabbix_agentd.d/\*.conf" /etc/zabbix/zabbix_agentd.conf &>/dev/null
if [ $? -en 0 ];then
sed -i 's#Include=/etc/zabbix/zabbix_agentd.d/#Include=/etc/zabbix/zabbix_agentd.d/*.conf#g' /etc/zabbix/zabbix_agentd.conf
fi
echo 'UserParameter=nginx_status[*],/bin/bash /etc/zabbix/scripts/nginx/nginx_status.sh "$1"'>/etc/zabbix/zabbix_agentd.d/nginx_status.conf
chmod +x /etc/zabbix/scripts/nginx_status.sh
/etc/init.d/zabbix-agent restart    
