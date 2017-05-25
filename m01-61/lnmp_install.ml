- hosts: 172.16.1.8
  tasks:
    - name: copy_all_script
      copy: src=/server/scripts/ dest=/server/scripts/
    - name: copy_all_tools
      copy: src=/home/oldboy/tools/  dest=/home/oldboy/tools/ 
    - name: install_nginx
      yum: name=/home/oldboy/tools/nginx-1.10.2-1.x86_64.rpm state=present
    - name: install_mysql
      yum: name=/home/oldboy/tools/mysql-5.6.34-1.x86_64.rpm state=present
    - name: install_php
      yum: name=/home/oldboy/tools/php-5.5.32-1.x86_64.rpm state=present

