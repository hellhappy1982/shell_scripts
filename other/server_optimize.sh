#1、规范功能目录

mkdir -p /home/tools /home/server/scripts

#2

echo "PS1='\[\e[32;1m\][\u@\h \W]\\$ \[\e[0m\]'" >>/etc/profile
. /etc/profile

#2、添加hosts解析

\cp /etc/hosts{,.bak}
cat >/etc/hosts<<EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.16.1.5      lb01
172.16.1.6      lb02
172.16.1.7      web02
172.16.1.8      web01
172.16.1.51     db01 db01.etiantian.org
172.16.1.31     nfs01
172.16.1.41     backup
172.16.1.61     m01
EOF


#3、更改yum源

mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup &&\
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
mv /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.backup
mv /etc/yum.repos.d/epel-testing.repo /etc/yum.repos.d/epel-testing.repo.backup
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-6.repo
 

#4、关闭selinux

sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config
setenforce 0
getenforce

#5、关闭iptables

/etc/init.d/iptables stop
/etc/init.d/iptables stop
chkconfig iptables off

#6、精简开机自启动服务

export LANG=en
chkconfig|egrep -v "crond|sshd|network|rsyslog|sysstat"|awk '{print "chkconfig",$1,"off"}'|bash
chkconfig --list|grep 3:on

#7、提权oldboy可以sudo

#useradd oldboy
#echo 123456|passwd --stdin oldboy
#\cp /etc/sudoers /etc/sudoers.ori
#echo "oldboy  ALL=(ALL) NOPASSWD: ALL " >>/etc/sudoers
#tail -1 /etc/sudoers
#visudo -c

#8、英文字符集

cp /etc/sysconfig/i18n /etc/sysconfig/i18n.ori
echo 'LANG="en_US.UTF-8"'  >/etc/sysconfig/i18n
source /etc/sysconfig/i18n
echo $LANG

#9、时间同步

echo '#time sync by aige at 2017-03-08' >>/var/spool/cron/root
echo '*/5 * * * * /usr/sbin/ntpdate pool.ntp.org >/dev/null 2>&1' >>/var/spool/cron/root
crontab -l

#10、命令行安全（可不设置）

#echo 'export TMOUT=300' >>/etc/profile
#echo 'export HISTSIZE=5' >>/etc/profile
#echo 'export HISTFILESIZE=5' >>/etc/profile
#tail -3 /etc/profile
#. /etc/profile

#11、加大文件描述

echo '*               -       nofile          65535 ' >>/etc/security/limits.conf
tail -1 /etc/security/limits.conf

#12、内核优化

cat >>/etc/sysctl.conf<<EOF
net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000    65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
#以下参数是对iptables防火墙的优化，防火墙不开会提示，可以忽略不理。
net.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
sysctl -p

#13、安装其他小软件

yum install lrzsz nmap tree dos2unix nc telnet sl -y

#14、ssh连接速度慢优化

sed -i.bak 's@#UseDNS yes@UseDNS no@g;s@^GSSAPIAuthentication yes@GSSAPIAuthentication no@g'  /etc/ssh/sshd_config
/etc/init.d/sshd reload