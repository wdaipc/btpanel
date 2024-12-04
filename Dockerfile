FROM centos:centos7.9.2009

# 切换 CentOS 镜像源为 CentOS Vault，更新包列表并安装依赖
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.tencent.com/repo/centos7_base.repo \
    && sed -i -e '/mirrors.cloud.tencent.com/d' -e '/mirrors.tencent.com/d' /etc/yum.repos.d/CentOS-Base.repo \
    && curl -o /etc/yum.repos.d/epel.repo https://mirrors.tencent.com/repo/epel-7.repo \
    && sed -i -e '/mirrors.cloud.tencent.com/d' -e '/mirrors.tencent.com/d' /etc/yum.repos.d/epel.repo \
    && yum clean all \
    && yum makecache \
    && yum update -y \
    && yum install -y \
    glibc-locale-source \
    wget iproute openssh-server gd-devel cmake make gcc gcc-c++ autoconf \
    libsodium-devel oniguruma-devel libssh2-devel c-ares-devel libaio-devel sudo curl dos2unix \
    bzip2 zip unzip tar ncurses-devel libtool libevent-devel openssl-devel cyrus-sasl-devel \
    libtool-ltdl-devel zlib-devel glib2 glib2-devel krb5-devel postgresql-devel gettext libcap-devel \
    uw-imap-devel psmisc patch git e2fsprogs libxslt-devel xz libwebp-devel libvpx-devel \
    freetype-devel libjpeg-turbo libjpeg-turbo-devel iptables systemd-devel openldap-devel \
    && yum clean all \
    && rm -rf /var/cache/yum

# 复制脚本
COPY ["bt.sh", "init_mysql.sh", "/"]

# 转换启动脚本
RUN dos2unix /bt.sh && dos2unix /init_mysql.sh

# 下载并安装宝塔面板及 lnmp 环境
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable \
    && rm -rf /www/server/data/* \
    && echo "docker_bt_c79" > /www/server/panel/data/o.pl \
    && echo '["memuA", "memuAsite", "memuAdatabase", "memuAcontrol", "memuAfiles", "memuAlogs", "memuAxterm", "memuAcrontab", "memuAsoft", "memuAconfig", "dologin", "memu_btwaf", "memuAssl"]' > /www/server/panel/config/show_menu.json \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* \
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