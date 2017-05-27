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
--with-mysql=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-iconv-dir=/usr/local/libiconv \
--with-freetype-dir \
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
--with-fpm-user=www \
--with-fpm-group=www \
--enable-ftp \
--enable-opcache=no

ln -s /application/mysql/lib/libmysqlclient.so.18  /usr/lib64/
touch ext/phar/phar.phar
make && make install       


ln -s /application/php-5.5.32/ /application/php

cd /home/oldboy/tools/php-5.5.32 &&\cp php.ini-production /application/php/lib/php.ini

echo "extension = mysqli.so" >> /application/php/lib/php.ini 

echo "extension = gettext.so " >> /application/php/lib/php.ini

cd /application/php/etc/ && \cp php-fpm.conf.default php-fpm.conf

useradd -s /sbin/nologin -M www

/application/php/sbin/php-fpm 

fpm -s dir -t rpm -n php-nom -v 5.5.32 -d 'libmcrypt-devel mhash mcrypt zlib-devel libxml2-devel libjpeg-devel libjpeg-turbo-devel curl-devel openssl-devel freetype-devel libpng-devel gd-devel libcurl-devel libxslt-devel libxslt-devel' --after-install /server/scripts/after_php.sh -f /application/php-5.5.32/








  