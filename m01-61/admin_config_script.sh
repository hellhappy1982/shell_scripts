#!bin/bash
# Source function library.
. /etc/rc.d/init.d/functions
mkdir -p /server/scripts/ /home/oldboy/tools/ /etc/ansible/playbook/ /application/yum/centos6/x86_64/
#amend yum.conf
sed -i 's#keepcache=0#keepcache=1#g' /etc/yum.conf
sed -i 's#/var/cache/#/application/#g' /etc/yum.conf

#vim_config
if [ ! -f .vimrc ];then
echo "set list
set lcs=tab:\|\ ,nbsp:%,trail:-
highlight LeaderTab guifg=#666666
match LeaderTab /^\t/
set ts=4
set expandtab
set pastetoggle=<F9>">~/.vimrc
fi

#PS1_config
echo "PS1='\[\e[32;1m\][\u@\h \W]\\$ \[\e[0m\]'" >>/etc/profile && . /etc/profile

#check rpm
yum install -y openssh sshpass ansible createrepo inotify                
#write_to_ip
[ $(grep "172.16.1.51" /etc/ansible/hosts | wc -l) -eq 0 ] &&
echo "[localip]
172.16.1.5
172.16.1.6
172.16.1.7
172.16.1.8
172.16.1.31
172.16.1.41
172.16.1.51" >> /etc/ansible/hosts

#yum_creat

createrepo -pdo /application/yum/centos6/x86_64/ /application/yum/centos6/x86_64/

createrepo --update /application/yum/centos6/x86_64/

cd /application/yum/centos6/x86_64/ && nohup python -m SimpleHTTPServer 81 >/dev/null 2>&1 &

echo "cd /application/yum/centos6/x86_64/ && nohup python -m SimpleHTTPServer 81 &>/dev/null &">>/etc/rc.local
if [ $? -eq 0 ]
	then
          action "yum_creat" /bin/true
    else
          action "yum_creat" /bin/false
fi
#time_sync
sed -i 's#restrict default kod nomodify notrap nopeer noquery#restrict  default  nomodify#g' /etc/ntp.conf
sed -i 's#restrict -6 default kod nomodify notrap nopeer noquery#\#restrict -6 default kod nomodify notrapnopeer noquery#g' /etc/ntp.conf
sed -i 's#server 0.centos.pool.ntp.org iburst#server ntp1.aliyun.com#g' /etc/ntp.conf
sed -i 's#server 1.centos.pool.ntp.org iburst#\#server 1.centos.pool.ntp.org iburst#g' /etc/ntp.conf
sed -i 's#server 2.centos.pool.ntp.org iburst#\#server 2.centos.pool.ntp.org iburst#g' /etc/ntp.conf
sed -i 's#server 3.centos.pool.ntp.org iburst#\#server 3.centos.pool.ntp.org iburst#g' /etc/ntp.conf
/etc/init.d/ntpd restart
echo "/etc/init.d/ntpd restart">>/etc/rc.local
if [ $? -eq 0 ]
	then
          action "time_sync" /bin/true
    else
          action "time_sync" /bin/false
fi
#creat_vpn
sed -i 's#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g' /etc/sysctl.conf
sysctl -p
yum -y install pptpd
sed -i 's#\#localip 192.168.0.1#localip 10.0.0.61#g' /etc/pptpd.conf
sed -i 's#\#remoteip 192.168.0.234-238,192.168.0.245#remoteip 172.16.1.234-238,172.16.1.245#g' /etc/pptpd.conf
sed -i 's#\#ms-dns 10.0.0.1#ms-dns 8.8.8.8#g' /etc/ppp/options.pptpd
sed -i 's#\#ms-dns 10.0.0.2#ms-dns 8.8.4.4#g' /etc/ppp/options.pptpd
echo "oldboy * 123456 *">>/etc/ppp/chap-secrets
chown 600 /etc/ppp/chap-secrets
echo -e 'echo "$PEERNAME admeasure IP: $5 login IP: $6 login time : "$(date -d today +%F_%T) >>/var/log/pptpd.log \nexit 0'>>/etc/ppp/ip-up
echo -e 'echo "$PEERNAME login IP: $6 down time : "$(date -d today +%F_%T)>>/var/log/pptpd.log \nexit 0'>>/etc/ppp/ip-down
/etc/init.d/pptpd restart
echo "/etc/init.d/pptpd restart">>/etc/rc.local
if [ $? -eq 0 ]
	then
          action "creat_vpn" /bin/true
    else
          action "creat_vpn" /bin/false
fi
#creat_iptables
modprobe iptable_filter
modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ipt_state
iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o eth0 -j SNAT --to-source 10.0.0.61
echo "iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o eth0 -j SNAT --to-source 10.0.0.61">>/etc/rc.local
if [ $? -eq 0 ]
	then
          action "creat_iptables" /bin/true
    else
          action "creat_iptables" /bin/false
fi
#zabbix_server
cd /home/oldboy/tools/ && tar xfP zabbix3.0.9_yum.tar.gz
yum -y --nogpgcheck -C install httpd zabbix-web zabbix-server-mysql zabbix-web-mysql zabbix-get mysql-server php55w php55w-mysql php55w-common php55w-gd php55w-mbstring php55w-mcrypt php55w-devel php55w-xml php55w-bcmath zabbix-get zabbix-java-gateway wqy-microhei-fonts net-snmp net-snmp-utils

\cp /usr/share/mysql/my-medium.cnf /etc/my.cnf

/etc/init.d/mysqld start

mysql -uroot -e"create database zabbix character set utf8 collate utf8_bin;"
mysql -uroot -e"grant all on zabbix.* to zabbix@'localhost' identified by 'zabbix';"
mysql -uroot -e"flush privileges;"

zcat /usr/share/doc/zabbix-server-mysql-3.0.9/create.sql.gz|mysql -uzabbix -pzabbix zabbix


sed -i 's#max_execution_time = 30#max_execution_time = 300#;s#max_input_time = 60#max_input_time = 300#;s#post_max_size = 8M#post_max_size = 16M#;910a date.timezone = Asia/Shanghai' /etc/php.ini


sed -i '115a DBPassword=zabbix' /etc/zabbix/zabbix_server.conf

cp -R /usr/share/zabbix/ /var/www/html/

chmod -R 755 /etc/zabbix/web
chown -R apache.apache /etc/zabbix/web 
echo "ServerName 127.0.0.1:80">>/etc/httpd/conf/httpd.conf

/etc/init.d/httpd start
/etc/init.d/zabbix-server start

#creat_dsa
if [ ! -f id_dsa ];then
    ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
fi

#sent dsa
for ip in 172.16.1.5 172.16.1.6 172.16.1.7 172.16.1.8 172.16.1.31 172.16.1.41 172.16.1.51
    do
     sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@$ip" &>/dev/null
    if [ $? -eq 0 ]
	then
          action "$(ssh $ip hostname)" /bin/true
    else
          action "$(ssh $ip hostname)" /bin/false
    fi
done

#start_playbook
cd /etc/ansible/playbook && ansible-playbook ansible_playbook.yml


