#!/bin/sh
cd /home/oldboy/tools/ && tar xf php-5.5.32.tar.gz
cd /home/oldboy/tools/php-5.5.32 && touch ext/phar/phar.phar
ln -s /application/php-5.5.32  /application/php
cd /home/oldboy/tools/php-5.5.32 && \cp php.ini-production /application/php/lib/php.ini
cd /application/php/etc/ && \cp php-fpm.conf.default php-fpm.conf