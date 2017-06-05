#!/bin/sh
ln -s /application/php-5.5.32  /application/php
cd /application/php/etc/ && \cp php-fpm.conf.default php-fpm.conf