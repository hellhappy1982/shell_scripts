#!/bin/bash

mkdir -p /etc/zabbix/scripts/
#yum chage
cd /etc/yum.repos.d/ && mkdir yum_bak
mv *repo yum_bak
echo "[localyum]
name=server
baseurl=http://172.16.1.61:81
enable=1
gpgcheck=0">localyum.repo 
yum clean all   

#local_time_sync
echo -e "#time sync \n*/5 * * * * /usr/sbin/ntpdate 172.16.1.61">/var/spool/cron/root

#eth1_conf
sed -i 's#ONBOOT=yes#ONBOOT=no#g' /etc/sysconfig/network-scripts/ifcfg-eth0
echo -e "DNS1=223.5.5.5\nDNS2=8.8.8.8\nGATEWAY=172.16.1.61" >>/etc/sysconfig/network-scripts/ifcfg-eth1
/etc/init.d/network restart   
           
#zabbix_agent_install
yum install -y zabbix-agent zabbix-get
sed -i 's#Server=127.0.0.1#Server=172.16.1.61#' /etc/zabbix/zabbix_agentd.conf
grep "zabbix_agentd.d/\*.conf" /etc/zabbix/zabbix_agentd.conf &>/dev/null
[ $? -en 0 ] && \
sed -i 's#Include=/etc/zabbix/zabbix_agentd.d/#Include=/etc/zabbix/zabbix_agentd.d/*.conf#g' /etc/zabbix/zabbix_agentd.conf
echo 'UserParameter=nginx_status[*],/bin/bash /etc/zabbix/scripts/nginx_status.sh "$1"'>/etc/zabbix/zabbix_agentd.d/nginx_status.conf
chmod +x /etc/zabbix/scripts/nginx_status.sh
/etc/init.d/zabbix-agent restart    
