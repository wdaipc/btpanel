FROM debian:bookworm

COPY bt.sh /bt.sh

# 设置构建参数
ARG RANDOM_NAME

# 设置一个btd12-前缀的随机主机名
RUN echo "btd12-${RANDOM_NAME}" > /etc/hostname

# 更新包列表
RUN apt update
RUN apt upgrade -y

# 安装前置依赖
RUN apt install -y wget iproute2 openssh-server libgd-dev cmake make gcc g++ autoconf \
    libsodium-dev libonig-dev libssh2-1-dev libc-ares-dev libaio-dev sudo curl

# 下载并安装宝塔面板
RUN curl -sSO https://download.bt.cn/install/install_panel.sh \
    && echo y | bash install_panel.sh -P 8888 --ssl-disable

# 配置宝塔面板安全入口和用户名及密码
RUN echo btpanel | bt 6 \
    && echo btpaneldocker | bt 5 \
    && echo "/btpanel" > /www/server/panel/data/admin_path.pl

# 设置 root 用户密码
RUN echo "root:btpaneldocker" | chpasswd

# 赋予 bt.sh 可执行权限
RUN chmod +x /bt.sh

# 清理缓存
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置标识文件
RUN echo "dk_lib_test_d12" > /www/server/panel/data/o.pl

ENTRYPOINT ["/bin/sh","-c","/bt.sh"]

# 暴漏所有端口
EXPOSE 0-65535

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD curl -i http://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1