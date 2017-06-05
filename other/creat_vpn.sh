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
echo "/etc/init.d/pptpd restart"/etc/rc.local