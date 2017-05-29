#!/bin/sh

yum install -y nginx keepalived
/application/nginx/sbin/nginx

#nginx_keep_conf
echo "worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    
    
    upstream server_pools { 
         server 10.0.0.7:80 weight=4 max_fails=3 fail_timeout=30s;
         server 10.0.0.8:80 weight=4 max_fails=3 fail_timeout=30s;
    }       
    
    server { 
       listen       80;
       server_name  www.etiantian.org;
       location / {
        proxy_pass http://server_pools; 
        proxy_set_header  Host \$host;
        proxy_set_header  X-Forwarded-For \$remote_addr; 
       }
    }
    server { 
       listen       80;
       server_name  bbs.etiantian.org;
       location / {
        proxy_pass http://server_pools; 
        proxy_set_header  Host \$host;
        proxy_set_header  X-Forwarded-For \$remote_addr; 
       }
    }
	server { 
       listen       80;
       server_name  blog.etiantian.org;
       location / {
        proxy_pass http://server_pools; 
        proxy_set_header  Host \$host;
        proxy_set_header  X-Forwarded-For \$remote_addr; 
       }
    }
}">/application/nginx/conf/nginx.conf
/application/nginx/sbin/nginx -s reload

#keep_conf_lb01
if [ $(hostname -I |cut -d . -f 7) -eq 5 ];then
echo "! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL
}

vrrp_script chk_web_proxy {                  
script "/server/scripts/chk_web_proxy.sh"    
interval 2                                   
weight 2
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
     10.0.0.3/24 dev eth0 label eth0:1  
    }
}

vrrp_instance VI_2 {
    state BACKUP
    interface eth0
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
     10.0.0.4/24 dev eth0 label eth0:2
    }
}">/etc/keepalived/keepalived.conf
fi
chmod +x /server/scripts/chk_web_proxy.sh
/etc/init.d/keepalived restart
##keep_conf_lb02
if [ $(hostname -I |cut -d . -f 7) -eq 6 ];then
echo "! Configuration File for keepalived

global_defs {
   router_id LVS_DEVEL1
}

vrrp_script chk_web_proxy {                  
script "/server/scripts/chk_web_proxy.sh"    
interval 2                                   
weight 2
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
     10.0.0.3/24 dev eth0 label eth0:1
    }
}

vrrp_instance VI_2 {
    state MASTER
    interface eth0
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
     10.0.0.4/24 dev eth0 label eth0:2
    }
}">/etc/keepalived/keepalived.conf
fi
chmod +x /server/scripts/chk_web_proxy.sh
/application/nginx/sbin/nginx -s reload
/etc/init.d/keepalived restart
 
