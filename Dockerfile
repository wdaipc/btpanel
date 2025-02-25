FROM debian:bookworm-slim

# 切换 Debian 镜像源为腾讯云源，更新包列表并安装依赖
RUN sed -i 's/deb.debian.org/mirrors.tencent.com/g' /etc/apt/sources.list.d/debian.sources \
    && apt update && apt upgrade -y \
    && apt install -y \
    locales \
    wget iproute2 openssh-server cmake make gcc g++ autoconf sudo curl dos2unix build-essential \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* 

# 复制脚本
COPY ["bt.sh", "init_mysql.sh", "/"]

# 转换启动脚本
RUN dos2unix /bt.sh && dos2unix /init_mysql.sh

# 下载并安装宝塔面板及 nginx
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable \
    && btpip config set global.index-url https://mirrors.tencent.com/pypi/simple \
    && mkdir /lnmp \
    && curl -o /lnmp/nginx.sh https://download.bt.cn/install/3/nginx.sh \
    && bash /lnmp/nginx.sh install 1.27 \ 
    && rm -rf /lnmp \
    && rm -rf /www/server/nginx/src \
    && echo "docker_bt_fnnas" > /www/server/panel/data/o.pl \
    && echo '["memuA", "memuAsite", "memuAwp", "memuAdatabase", "memuAcontrol", "memuAfiles", "memuAlogs", "memuAxterm", "memuAcrontab", "memuAsoft", "memuAconfig", "dologin", "memu_btwaf", "memuAssl"]' > /www/server/panel/config/show_menu.json \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /www/reserve_space.pl \
    && chmod +x /bt.sh \
    && chmod +x /init_mysql.sh
    

# 配置宝塔面板安全入口和用户名及密码，以及 SSH 密码
RUN echo btpanel | bt 6 \
    && echo btpaneldocker | bt 5 \
    && echo "/btpanel" > /www/server/panel/data/admin_path.pl \
    && echo "root:btpaneldocker" | chpasswd

# 打包宝塔面板，并清除www
RUN bt 2 \
    && tar -zcf /www.tar.gz /www \
    && rm -rf /www

ENTRYPOINT ["/bin/sh","-c","/bt.sh"]

# 暴漏特定端口
EXPOSE 22 80 443 888 3306 8888

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD prot="http"; if [ -f "/www/server/panel/data/ssl.pl" ]; then prot="https"; fi; curl -k -i $prot://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1