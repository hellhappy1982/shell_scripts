#!/bin/sh
if [ `ss -lntup|grep nginx|wc -l` -ne 2 ];then /etc/init.d/keepalived stop fi