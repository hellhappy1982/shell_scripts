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
/etc/init.d/ntpd start
if [ $(ntpstat|wc -l) -eq 3 ];then
	chkconfig ntpd on
else
    /etc/init.d/ntpd restart
fi
echo "/etc/init.d/ntpd restart">>/etc/rc.local
#creat dsa
if [ ! -f id_dsa ];then
    ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
fi








