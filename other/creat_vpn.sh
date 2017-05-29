sed -i 's#net.ipv4.ip_forward = 0#net.ipv4.ip_forward = 1#g' /etc/sysctl.conf
sysctl -p
yum -y install pptpd
echo -e "localip 10.0.0.61 \nremoteip 172.16.1.0-250">>/etc/pptpd.conf
echo "oldboy * 123456 *">>/etc/ppp/chap-secrets
chown 600 /etc/ppp/chap-secrets
/etc/init.d/pptpd start
ip add
echo -e 'echo "$PEERNAME admeasure IP: $5 login IP: $6 login time : "$(date -d today +%F_%T) >>/var/log/pptpd.log \nexit 0'>>/etc/ppp/ip-up
echo -e 'echo "$PEERNAME login IP: $6 down time : "$(date -d today +%F_%T)>>/var/log/pptpd.log \nexit 0'>>/etc/ppp/ip-down
/etc/init.d/pptpd restart