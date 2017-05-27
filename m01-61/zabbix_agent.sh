yum -y  localinstall http://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/6/x86_64/zabbix-agent-3.0.9-1.el6.x86_64.rpm
sed -i 's#Server=127.0.0.1#Server=172.16.1.61#' /etc/zabbix/zabbix_agentd.conf
/etc/init.d/zabbix-agent start