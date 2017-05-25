#!/bin/bash
if [ ! -d nginx-1.10.2 ];then
    cd /home/oldboy/tools/  && tar xf nginx-1.10.2.tar.gz -C /usr/local/
else
	exit 1
fi
if [ $(rpm -qa pcre-devel openssl-devel |wc -l) -eq 0 ];then
    yum install -y pcre-devel openssl-devel 
fi
if [ $(grep "www" /etc/passwd|wc -l) -eq 0 ];then
	useradd -s /sbin/nologin -M www
fi
cd /usr/local/nginx-1.10.2 && ./configure --user=www --group=www --prefix=/application/nginx --with-http_stub_status_module --with-http_ssl_module
cd /usr/local/nginx-1.10.2 && make
cd /usr/local/nginx-1.10.2 && make install
ln -s /app/application/nginx-1.10.2 /application/nginx
chown -R www. /application/nginx*/
/application/nginx/sbin/nginx
cd /application/nginx/conf/ && egrep -v "#|^$" nginx.conf.default|sed '16,20d'>nginx.conf

#nginx_add_PATH
echo 'export PATH=/application/nginx/sbin:$PATH' >>/etc/profile
source /etc/profile


