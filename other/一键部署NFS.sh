#!/bin/bash
#一：分发秘钥
###rm the before ssh-key
\rm -f /root/.ssh/*;ssh-keygen -t dsa -f /root/.ssh/id_dsa -P "" -q
###
for i in {31,41,7,8}
do
sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@172.16.1.$i" >/dev/null 2>&1
done

###二：部署NFS
##第一步：安装nfs-utils（nfs服务器上）
ansible 172.16.1.31 -m yum -a "name=nfs-utils state=installed"
###第二步：开启rpc服务(nfs服务器上)
ansible 172.16.1.31 -m service -a "name=rpcbind state=started"
##第三步：开启nfs服务（nfs服务器上）
ansible 172.16.1.31 -m service -a "name=nfs state=started"
##第四步：创建共享目录（nfs服务器上）
ansible 172.16.1.31 -m file -a "path=/data state=directory"
##第五步：授权共享目录的属组和属主为nfsnobody(nfs服务器上)
ansible 172.16.1.31 -m command -a "chown nfsnobody.nfsnobody /data"
##第六步：修改配置文件/etc/exports,并传到nfs服务器上
echo "/data 172.16.1.0/24(rw,sync)" >/etc/exports
ansible 172.16.1.31 -m copy -a "src=/server/scripts/exports dest=/etc/exports"
##第七步：重启nfs服务器的nfs服务配置文件
ansible 172.16.1.31 -m command -a "/etc/init.d/nfs reload"
##配置web01 ,web02
##第一步：查看挂载资源
ansible nfs -m command -a "showmount -e 172.16.1.31"
##第二步：web01,web02挂载nfs共享目录
ansible nfs -m mount -a "name=/mnt src=172.16.1.31:/data fstype=nfs state=mounted"
