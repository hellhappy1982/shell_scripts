#!bin/bash

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

echo "[hellhappy]
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

cd /application/yum/centos6/x86_64/ && nohup python -m SimpleHTTPServer 81 &>/dev/null &

echo "cd /application/yum/centos6/x86_64/ && nohup python -m SimpleHTTPServer 81 &>/dev/null &">>/etc/rc.local

#time_sync

sed -i 's#restrict default kod nomodify notrap nopeer noquery#restrict  default  nomodify#g' /etc/ntp.conf
sed -i 's#restrict -6 default kod nomodify notrap nopeer noquery#\#restrict -6 default kod nomodify notrapnopeer noquery#g' /etc/ntp.conf
sed -i 's#server 0.centos.pool.ntp.org iburst#server ntp1.aliyun.com#g' /etc/ntp.conf
sed -i 's#server 1.centos.pool.ntp.org iburst#\#server 1.centos.pool.ntp.org iburst#g' /etc/ntp.conf
sed -i 's#server 2.centos.pool.ntp.org iburst#\#server 2.centos.pool.ntp.org iburst#g' /etc/ntp.conf
sed -i 's#server 3.centos.pool.ntp.org iburst#\#server 3.centos.pool.ntp.org iburst#g' /etc/ntp.conf
/etc/init.d/ntpd restart
fi
echo "/etc/init.d/ntpd restart">>/etc/rc.local

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

#creat_iptables
modprobe iptable_filter
modprobe iptable_nat
modprobe ip_conntrack
modprobe ip_conntrack_ftp
modprobe ip_nat_ftp
modprobe ipt_state
iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o eth0 -j SNAT --to-source 10.0.0.61
echo "iptables -t nat -A POSTROUTING -s 172.16.1.0/24 -o eth0 -j SNAT --to-source 10.0.0.61">>/etc/rc.local
#creat_dsa
if [ ! -f id_dsa ];then
    ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
fi








