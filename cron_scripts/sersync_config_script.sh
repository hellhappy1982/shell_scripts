#!/bin/sh

#tra_sersync
cd /home/oldboy/tools/  && tar xf sersync.tar.gz -C /usr/local/

mkdir -p /application/logs/

#start_sersync
/usr/local/sersync/bin/sersync -r -d -o /usr/local/sersync/conf/confxml.xml

#write_to_rc.local
echo "/usr/local/sersync/bin/sersync -r -d -o /usr/local/sersync/conf/confxml.xml">>/etc/rc.local
