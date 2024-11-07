FROM debian:bookworm

# 切换 Debian 镜像源为腾讯云源，更新包列表并安装依赖
RUN sed -i 's/deb.debian.org/mirrors.tencent.com/g' /etc/apt/sources.list.d/debian.sources \
    && apt update && apt upgrade -y \
    && apt install -y \
    locales \
    wget iproute2 openssh-server libgd-dev cmake make gcc g++ autoconf \
    libsodium-dev libonig-dev libssh2-1-dev libc-ares-dev libaio-dev sudo curl dos2unix \
    build-essential re2c cron bzip2 libzip-dev libc6-dev bison file rcconf flex vim m4 gawk less cpp binutils \
    diffutils unzip tar libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev libssl-dev libsasl2-dev \
    libltdl-dev zlib1g-dev libglib2.0-0 libglib2.0-dev libkrb5-dev libpq-dev libpq5 gettext libcap-dev \
    libc-client2007e-dev psmisc patch git e2fsprogs libxslt1-dev xz-utils libgd3 libwebp-dev libvpx-dev \
    libfreetype6-dev libjpeg62-turbo libjpeg62-turbo-dev iptables libudev-dev libldap2-dev \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* 

# 复制脚本
COPY ["bt.sh", "init_mysql.sh", "/"]
COPY ["phpmyadmin.sh", "/lamp/"]

# 转换启动脚本
RUN dos2unix /bt.sh && dos2unix /init_mysql.sh

# 下载并安装宝塔面板及 lamp 环境
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable \
    && curl -o /lamp/apache.sh https://download.bt.cn/install/4/apache.sh \
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
    && rm -rf /www/server/nginx/src \
    && echo "docker_btlamp_d12" > /www/server/panel/data/o.pl \
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