#!/bin/sh
date_format=`data +%F`
base_dir="/application/nginx"
nginx_log_dir="$base_dir/logs"
log_name="access_www"
[ -d $nginx_log_dir ] && cd $nginx_log_dir || exit 1
[ -f ${log_name}.log ] || exit 1
mv ${log_name}.log ${date_format}_${log_name}.log
$base_dir/sbin/nginx -s reload