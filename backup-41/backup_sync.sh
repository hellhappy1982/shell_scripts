###backup sync sript

#check file
find /backup/ -type f -name "*txt" |xargs md5sum -c >/tmp/finger_check.txt

#set mail
mail -s "check file" 25487092@qq.com</tmp/finger_check.txt

#delete 180 days save week01\
rm -f $(find /backup/ -type f -mtime +180 ! -name "*week01.tar.gz")
