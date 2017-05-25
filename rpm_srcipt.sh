yum -y install ruby rubygems ruby-devel
gem sources list
gem sources --add https://ruby.taobao.org/ --remove http://rubygems.org/
cd /home/oldboy/tools/ && rpm -ivh fpm-1.6.3-1.x86_64.rpm
