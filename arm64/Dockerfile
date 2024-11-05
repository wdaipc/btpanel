FROM debian:bookworm

# 切换 Debian 镜像源为腾讯云源
RUN sed -i 's/deb.debian.org/mirrors.tencent.com/g' /etc/apt/sources.list.d/debian.sources

# 更新包列表并升级系统中已经安装的软件包
RUN apt update && apt upgrade -y

# 安装前置依赖
RUN apt install -y \
    locales \
    wget iproute2 openssh-server libgd-dev cmake make gcc g++ autoconf \
    libsodium-dev libonig-dev libssh2-1-dev libc-ares-dev libaio-dev sudo curl dos2unix \
    build-essential re2c cron bzip2 libzip-dev libc6-dev bison file rcconf flex vim m4 gawk less cpp binutils \
    diffutils unzip tar libbz2-dev libncurses5 libncurses5-dev libtool libevent-dev libssl-dev libsasl2-dev \
    libltdl-dev zlib1g-dev libglib2.0-0 libglib2.0-dev libkrb5-dev libpq-dev libpq5 gettext libcap-dev \
    libc-client2007e-dev psmisc patch git e2fsprogs libxslt1-dev xz-utils libgd3 libwebp-dev libvpx-dev \
    libfreetype6-dev libjpeg62-turbo libjpeg62-turbo-dev iptables libudev-dev libldap2-dev

# 配置区域设置
RUN locale-gen en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && export LANGUAGE=en_US:en \
    && export LC_ALL=en_US.UTF-8 \
    && export LC_CTYPE=en_US.UTF-8 \
    && update-locale

# 复制启动脚本
COPY bt.sh /bt.sh
COPY init_mysql.sh /init_mysql.sh

# 转换启动脚本
RUN dos2unix /bt.sh
RUN dos2unix /init_mysql.sh

# 设置构建参数
ARG RANDOM_NAME

# 设置一个btd12-前缀的随机主机名
RUN echo "btd12-${RANDOM_NAME}" > /etc/hostname

# 下载并安装宝塔面板
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable

# 安装 lnmp 环境
# 创建目录
RUN mkdir -p /lnmp

# 安装 lnmp 环境
# 创建目录
RUN mkdir -p /lnmp

# 安装 Nginx 1.27
RUN curl -o /lnmp/nginx.sh https://download.bt.cn/install/3/nginx.sh \
    && sh /lnmp/nginx.sh install openresty

# 安装 PHP 8.3
RUN curl -o /lnmp/php.sh https://download.bt.cn/install/4/php.sh \
    && sh /lnmp/php.sh install 8.3

# 安装 MySQL 8.0
RUN curl -o /lnmp/mysql.sh https://download.bt.cn/install/4/mysql.sh \
    && sh /lnmp/mysql.sh install 8.0

# 安装 phpmyadmin 5.1
RUN curl -o /lnmp/phpmyadmin.sh https://download.bt.cn/install/4/phpmyadmin.sh \
    && sh /lnmp/phpmyadmin.sh install 5.1

# 清理安装包
RUN rm -rf /lnmp \
    && rm -rf /www/server/php/83/src \
    && rm -rf /www/server/mysql/mysql-test \
    && rm -rf /www/server/mysql/src.tar.gz \
    && rm -rf /www/server/mysql/src \
    && rm -rf /www/server/nginx/src \
    && rm -rf /www/server/data/*

# 配置宝塔面板安全入口和用户名及密码
RUN echo btpanel | bt 6 \
    && echo btpaneldocker | bt 5 \
    && echo "/btpanel" > /www/server/panel/data/admin_path.pl

# 设置 root 用户密码
RUN echo "root:btpaneldocker" | chpasswd

# 赋予 bt.sh 可执行权限
RUN chmod +x /bt.sh

# 清理缓存
RUN apt clean \
    && rm -rf /var/lib/apt/lists/*

# 设置标识文件
RUN echo "docker_btlnmp_d12" > /www/server/panel/data/o.pl

ENTRYPOINT ["/bin/sh","-c","/bt.sh"]

# 暴漏所有端口
EXPOSE 0-65535

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD curl -i http://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1