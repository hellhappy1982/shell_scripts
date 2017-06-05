#!/bin/sh

yum install zlib-devel libxml2-devel libjpeg-devel libjpeg-turbo-devel -y
yum install freetype-devel libpng-devel gd-devel libcurl-devel libxslt-devel libxslt-devel -y

cd /home/oldboy/tools && tar zxf libiconv-1.14.tar.gz

cd libiconv-1.14 && ./configure --prefix=/usr/local/libiconv

make

make install

yum -y install libmcrypt-devel mhash mcrypt openssl openssl-devel

cd /home/oldboy/tools/ && tar xf php-5.5.32.tar.gz
cd php-5.5.32
./configure \
--prefix=/application/php-5.5.32 \
--with-mysql=/application/mysql/ \
--with-pdo-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-iconv-dir=/usr/local/libiconv \
--with-freetype-dir \
--with-gettext \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--enable-xml \
--disable-rpath \
--enable-bcmath \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--with-curl \
--enable-mbregex \
--enable-fpm \
--enable-mbstring \
--with-mcrypt \
--with-gd \
--enable-gd-native-ttf \
--with-openssl \
--with-mhash \
--enable-pcntl \
--enable-sockets \
--with-xmlrpc \
--enable-soap \
--enable-short-tags \
--enable-static \
--with-xsl \
--witnoh-fpm-user=www \
--with-fpm-group=www \
--enable-ftp \
--enable-opcache=no

ln -s /application/mysql/lib/libmysqlclient.so.18  /usr/lib64/
touch ext/phar/phar.phar
make && make install       

cd /home/oldboy/tools/php-5.5.32 &&\cp php.ini-production /application/php-5.5.32/lib/php.ini

cd /application/php-5.5.32/etc/ && \cp php-fpm.conf.default php-fpm.conf

ln -s /application/php-5.5.32/ /application/php

useradd -s /sbin/nologin -M www

sed -i 's#max_execution_time = 30#max_execution_time = 300#;s#max_input_time = 60#max_input_time = 300#;s#post_max_size = 8M#post_max_size = 16M#;910a date.timezone = Asia/Shanghai' /application/php-5.5.32/lib/php.ini







  