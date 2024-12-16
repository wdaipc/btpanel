FROM debian:bookworm

COPY ["bt.sh", "init_mysql.sh", "/"]

RUN sed -i 's/deb.debian.org/mirrors.tencent.com/g' /etc/apt/sources.list.d/debian.sources && \
    apt update && apt upgrade -y && \
    apt install -y \
    locales \
    wget openssh-server cmake make gcc g++ autoconf sudo curl dos2unix build-essential && \
    dos2unix /bt.sh && dos2unix /init_mysql.sh && \
    curl -sSO https://download.bt.cn/install/install_panel.sh && \
    echo y | bash install_panel.sh -P 8888 --ssl-disable && \
    mkdir /lnmp && \
    curl -o /lnmp/nginx.sh https://download.bt.cn/install/3/nginx.sh && \
    bash /lnmp/nginx.sh install openresty && \ 
    rm -rf /lnmp && \
    rm -rf /www/server/nginx/src && \
    echo "docker_bt_nas" > /www/server/panel/data/o.pl && \
    echo '["memuA", "memuAsite", "memuAdatabase", "memuAcontrol", "memuAfiles", "memuAlogs", "memuAxterm", "memuAcrontab", "memuAsoft", "memuAconfig", "dologin", "memu_btwaf", "memuAssl"]' > /www/server/panel/config/show_menu.json && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod +x /bt.sh && \
    chmod +x /init_mysql.sh && \
    echo btpanel | bt 6 && \
    echo btpaneldocker | bt 5 && \
    echo "/btpanel" > /www/server/panel/data/admin_path.pl && \
    echo "root:btpaneldocker" | chpasswd

ENTRYPOINT ["/bin/sh","-c","/bt.sh"]

# 暴漏所有端口
EXPOSE 0-65535

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD prot="http"; if [ -f "/www/server/panel/data/ssl.pl" ]; then prot="https"; fi; curl -k -i $prot://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1