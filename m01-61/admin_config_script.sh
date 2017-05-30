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
echo "# For more information about this file, see the man pages
# ntp.conf(5), ntp_acc(5), ntp_auth(5), ntp_clock(5), ntp_misc(5), ntp_mon(5).

driftfile /var/lib/ntp/drift

# Permit time synchronization with our time source, but do not
# permit the source to query or modify the service on this system.
#restrict default kod nomodify notrap nopeer noquery
#restrict -6 default kod nomodify notrap nopeer noquery
restrict  default  nomodify

# Permit all access over the loopback interface.  This could
# be tightened as well, but to do so would effect some of
# the administrative functions.
restrict 127.0.0.1 
restrict -6 ::1

# Hosts on local network are less restricted.
#restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
server ntp1.aliyun.com
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst

#broadcast 192.168.1.255 autokey	# broadcast server
#broadcastclient			# broadcast client
#broadcast 224.0.1.1 autokey		# multicast server
#multicastclient 224.0.1.1		# multicast client
#manycastserver 239.255.254.254		# manycast server
#manycastclient 239.255.254.254 autokey # manycast client

# Enable public key cryptography.
#crypto

includefile /etc/ntp/crypto/pw

# Key file containing the keys and key identifiers used when operating
# with symmetric key cryptography. 
keys /etc/ntp/keys

# Specify the key identifiers which are trusted.
#trustedkey 4 8 42

# Specify the key identifier to use with the ntpdc utility.
#requestkey 8

# Specify the key identifier to use with the ntpq utility.
#controlkey 8

# Enable writing of statistics records.
#statistics clockstats cryptostats loopstats peerstats">/etc/ntp.conf
/etc/init.d/ntpd start
if [ $(ntpstat|wc -l) -eq 3 ];then
	chkconfig ntpd on
else
    /etc/init.d/ntpd restart
fi

#creat dsa
if [ ! -f id_dsa ];then
    ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
fi








