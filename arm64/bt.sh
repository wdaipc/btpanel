#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

init_path=/etc/init.d
Root_Path=`cat /var/bt_setupPath.conf`
Setup_Path=$Root_Path/server/mysql
Data_Path=$Root_Path/server/data

soft_start(){
    ${init_path}/nginx start
    ${init_path}/php-fpm-83 start
    ${init_path}/bt restart
    pkill crond
    /sbin/crond
    /usr/sbin/sshd -D &
}

is_empty_Data(){
    return `ls -A ${Data_Path}/|wc -w`
}

start_mysql(){
    chown -R mysql:mysql ${Data_Path}
    chgrp -R mysql ${Setup_Path}/.
    ${init_path}/mysqld start
    rm -f /init_mysql.sh
}

soft_start > /dev/null
is_empty_Data > /dev/null
start_mysql > /dev/null
tail -f /dev/null
