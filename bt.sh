#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

init_path=/etc/init.d
Root_Path=`cat /var/bt_setupPath.conf`
Setup_Path=$Root_Path/server/mysql
Data_Path=$Root_Path/server/data
O_pl=$(cat /www/server/panel/data/o.pl)

backup_database() {
  if [ -d "${Data_Path}" ] && [ ! -z "$(ls -A ${Data_Path})" ]; then
    if [ ! -d "${Setup_Path}" ] || [ -z "$(ls -A ${Setup_Path})" ]; then
      timestamp=$(date +"%s")
      tar czf /www/server/data_backup_$timestamp.tar.gz -C ${Data_Path} .
    fi
  fi
}

restore_panel_data() {
  if [ -f /www.tar.gz ]; then
    if [ ! -d /www ] || [ -z "$(ls -A /www)" ] || [ ! -d /www/server/panel ] || [ -z "$(ls -A /www/server/panel)" ] || [ ! -d /www/server/panel/pyenv ] || [ -z "$(ls -A /www/server/panel/pyenv)" ]; then
      tar xzf /www.tar.gz -C / --skip-old-files
      rm -rf /www.tar.gz
    fi
  fi
}

soft_start(){
    init_scripts=$(ls ${init_path})
    for script in ${init_scripts}; do
        case "${script}" in
        "bt"|"mysqld"|"nginx"|"httpd")
            continue
            ;;
        esac
        ${init_path}/${script} start
    done

    if [ -f ${init_path}/nginx ]; then
        ${init_path}/nginx start
    elif [ -f ${init_path}/httpd ]; then
        ${init_path}/httpd start
    fi

    ${init_path}/bt stop
    ${init_path}/bt start

    pkill crond
    /sbin/crond

    chmod 600 /etc/ssh/ssh_host_*
    /usr/sbin/sshd -D &
}

init_mysql(){
    if [ "${O_pl}" != "docker_btlamp_fnnas" ] && [ "${O_pl}" != "docker_btlnmp_fnnas" ];then
        return
    fi
    if [ -d "${Data_Path}" ]; then
        check_z=$(ls "${Data_Path}")
        if [[ ! -z "${check_z}" ]]; then
            return
        fi
    fi
    if [ -f /init_mysql.sh ] && [ -d "${Setup_Path}" ];then
        bash /init_mysql.sh
        rm -f /init_mysql.sh
    fi
}

is_empty_Data(){
    return "$(ls -A ${Data_Path}/|wc -w)"
}

start_mysql(){
    if [ -d "${Setup_Path}" ] && [ -f "${init_path}/mysqld" ];then
        chown -R mysql:mysql ${Data_Path}
        chgrp -R mysql ${Setup_Path}/.
        ${init_path}/mysqld start
    fi
}

check_bt_credentials() {
    if [ -f "/www/server/panel/data/credentials_set" ]; then
        echo "Credentials already set. Skipping."
        return 0
    fi

    if [ -z "$btuser" ] && [ -z "$btpwd" ]; then
        echo "No credentials provided. Skipping."
        return 0
    fi

    echo "Waiting for BT panel to be ready..."
    while true; do
        ${init_path}/bt status >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            break
        fi
        sleep 1
        echo "Retrying..."
    done

    if [ -n "$btuser" ]; then
        echo "Updating username to $btuser..."
        echo "$btuser" | ${init_path}/bt 6 || echo "Failed to update username."
    fi

    if [ -n "$btpwd" ]; then
        echo "Updating password..."
        echo "$btpwd" | ${init_path}/bt 5 || echo "Failed to update password."
    fi

    touch "/www/server/panel/data/credentials_set"
}

restore_panel_data > /dev/null
backup_database > /dev/null
is_empty_Data > /dev/null
init_mysql > /dev/null
start_mysql > /dev/null
soft_start > /dev/null
check_bt_credentials > /dev/null
${init_path}/bt log
