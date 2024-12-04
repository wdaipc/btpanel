FROM rockylinux:9

# 切换 rockylinux 镜像源为腾讯云源，更新包列表并安装依赖
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.tencent.com/rocky|g' \
    -i.bak \
    /etc/yum.repos.d/Rocky-*.repo \
    && yum makecache \
    && yum config-manager --set-enabled devel \
    && yum update -y \
    && yum install -y \
    glibc-locale-source \
    wget iproute openssh-server gd-devel cmake make gcc gcc-c++ autoconf \
    libsodium-devel oniguruma libssh2-devel c-ares-devel libaio-devel sudo curl dos2unix \
    bzip2 zip unzip tar ncurses-devel libtool libevent-devel openssl-devel cyrus-sasl-devel \
    libtool-libs zlib-devel glib2 glib2-devel krb5-devel postgresql-devel gettext libcap-devel \
    oniguruma-devel psmisc patch git e2fsprogs libxslt-devel xz libwebp-devel libvpx-devel \
    freetype-devel libjpeg-turbo libjpeg-turbo-devel iptables systemd-devel openldap-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

# 复制脚本
COPY ["bt.sh", "init_mysql.sh", "/"]
COPY ["phpmyadmin.sh", "/lamp/"]

# 转换启动脚本
RUN dos2unix /bt.sh && dos2unix /init_mysql.sh

# 下载并安装宝塔面板及 lnmp 环境
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable

RUN curl -o /lamp/apache.sh https://download.bt.cn/install/0/apache.sh \
    && sh /lamp/apache.sh install 2.4 \ 
    && curl -o /lamp/php.sh https://download.bt.cn/install/4/php.sh \
    && sh /lamp/php.sh install 8.3 \
    && curl -o /lamp/mysql.sh https://download.bt.cn/install/4/mysql.sh \
    && sh /lamp/mysql.sh install 8.0 \
    && sh /lamp/phpmyadmin.sh install 5.2 \
    && rm -rf /lamp \
    && rm -rf /www/server/php/83/src \
    && rm -rf /www/server/mysql/mysql-test \
    && rm -rf /www/server/mysql/src.tar.gz \
    && rm -rf /www/server/mysql/src \
    && rm -rf /www/server/data/* \
    && rm -rf /www/server/apache/src \
    && echo "docker_btlamp_c79" > /www/server/panel/data/o.pl \
    && echo '["memuA", "memuAsite", "memuAdatabase", "memuAcontrol", "memuAfiles", "memuAlogs", "memuAxterm", "memuAcrontab", "memuAsoft", "memuAconfig", "dologin", "memu_btwaf", "memuAssl"]' > /www/server/panel/config/show_menu.json \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && chmod +x /bt.sh \
    && chmod +x /init_mysql.sh
    

# 配置宝塔面板安全入口和用户名及密码，以及 SSH 密码
RUN echo btpanel | bt 6 \
    && echo btpaneldocker | bt 5 \
    && echo "/btpanel" > /www/server/panel/data/admin_path.pl \
    && echo "root:btpaneldocker" | chpasswd

ENTRYPOINT ["/bin/sh","-c","/bt.sh"]

# 暴漏所有端口
EXPOSE 0-65535

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD curl -i http://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1