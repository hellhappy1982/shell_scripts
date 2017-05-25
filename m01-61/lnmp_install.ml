- hosts: 172.16.1.8
  tasks:
    - name: copy_all_script
      copy: src=/server/scripts/ dest=/server/scripts/
    - name: copy_all_tools
      copy: src=/home/oldboy/tools/  dest=/home/oldboy/tools/ 
    - name: install_nginx
      yum: name=nginx-1.10.2-1.x86_64.rpm state=present
    - name: libiconv_install
      script: /server/scripts/libiconv_install.sh 
	- name: install_php
      yum: name=php-5.5.32-5m.x86_64.rpm state=present
- hosts: 172.16.1.8
  tasks:
    - name: install_mysql
      yum: name=mysql-5.6.34-1.x86_64.rpm state=present
