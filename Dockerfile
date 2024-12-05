FROM rockylinux:9

# 设置构建参数
ARG RANDOM_NAME

# 设置一个随机主机名
RUN echo "btr9-${RANDOM_NAME}" > /etc/hostname

# 切换 rockylinux 镜像源为腾讯云源，更新包列表并安装依赖
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.tencent.com/rocky|g' -i.bak /etc/yum.repos.d/rocky-*.repo && \
    dnf makecache && \
    (dnf install -y epel-release || dnf install -y epol-release 'dnf-command(config-manager)') && \
    (dnf config-manager --set-enabled powertools || dnf config-manager --set-enabled crb) || true && \
    dnf repolist && \
    dnf update -y && \
    dnf install -y perl perl-devel procps-ng which glibc-locale-source util-linux wget iproute openssh-server gd-devel cmake make gcc gcc-c++ autoconf libsodium-devel oniguruma libssh2-devel c-ares-devel libaio-devel sudo dos2unix bzip2 zip unzip tar ncurses-devel libtool libevent-devel openssl-devel cyrus-sasl-devel libtool-libs zlib-devel glib2 glib2-devel krb5-devel postgresql-devel gettext libcap-devel oniguruma-devel psmisc patch git e2fsprogs libxslt-devel xz libwebp-devel libvpx-devel freetype-devel libjpeg-turbo libjpeg-turbo-devel iptables systemd-devel openldap-devel && \
    dnf clean all && \
    rm -rf /var/cache/dnf

# 复制脚本
COPY ["bt.sh", "init_mysql.sh", "/"]

# 转换启动脚本
RUN dos2unix /bt.sh && dos2unix /init_mysql.sh

# 下载并安装宝塔面板及 lnmp 环境
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable \
    && rm -rf /www/server/data/* \
    && echo "docker_bt_r9" > /www/server/panel/data/o.pl \
    && echo '["memuA", "memuAsite", "memuAdatabase", "memuAcontrol", "memuAfiles", "memuAlogs", "memuAxterm", "memuAcrontab", "memuAsoft", "memuAconfig", "dologin", "memu_btwaf", "memuAssl"]' > /www/server/panel/config/show_menu.json \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && chmod +x /bt.sh \
    && chmod +x /init_mysql.sh
    

# 配置宝塔面板安全入口和用户名及密码，以及 SSH 密码
RUN echo btpanel | bt 6 \
    && echo btpaneldocker | bt 5 \
    && echo "/btpanel" > /www/server/panel/data/admin_path.pl \
    && echo "root:btpaneldocker" | chpasswd

ENTRYPOINT ["/bin/bash","-c","/bt.sh"]

# 暴漏所有端口
EXPOSE 0-65535

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD curl -i http://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1