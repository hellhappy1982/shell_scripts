#!/bin/bash
# Source function library.
. /etc/rc.d/init.d/functions
#sent dsa
for ip in $*
    do
     sshpass -p123456 ssh-copy-id -i /root/.ssh/id_dsa.pub "-o StrictHostKeyChecking=no root@$ip" &>/dev/null
    if [ $? -eq 0 ]
	then
          action "$(ssh $ip hostname)" /bin/true
    else
          action "$(ssh $ip hostname)" /bin/false
    fi
done