#!/bin/sh
sed -i 's#ONBOOT=no#ONBOOT=yes#g' /etc/sysconfig/network-scripts/ifcfg-eth0
/etc/init.d/network restart
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
         server 172.16.1.7:80 weight=1 max_fails=3 fail_timeout=30s;
         server 172.16.1.8:80 weight=1 max_fails=3 fail_timeout=30s;
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

#keep_conf_lb01
[ $(hostname -I |cut -d . -f 7) -eq 5 ] && \
echo "! Configuration File for keepalived

global_defs {
   router_id lb01
}

vrrp_script chk_web_proxy {                  
script "/home/oldboy/scripts/chk_web_proxy.sh"    
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
	  track_script {
    chk_web_proxy  
    }
}">/etc/keepalived/keepalived.conf

##keep_conf_lb02
[ $(hostname -I |cut -d . -f 7) -eq 6 ] && \
echo "! Configuration File for keepalived

global_defs {
   router_id lb02
}

vrrp_script chk_web_proxy {                  
script "/home/oldboy/scripts/chk_web_proxy.sh"    
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
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
     10.0.0.4/24 dev eth0 label eth0:2
    }
	  track_script {
    chk_web_proxy  
    }
}">/etc/keepalived/keepalived.conf
chmod +x /server/scripts/chk_web_proxy.sh
/application/nginx/sbin/nginx -s reload
/etc/init.d/keepalived restart
 
