/etc/init.d/bt restart
pkill crond
/sbin/crond
/usr/sbin/sshd -D &
tail -f /dev/null
