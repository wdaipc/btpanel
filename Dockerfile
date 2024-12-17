FROM alpine

# 切换 alpine 镜像源为腾讯云源，更新包列表并安装依赖
RUN apk update && apk upgrade \
    && apk add curl curl-dev libffi-dev openssl-dev shadow bash zlib-dev g++ make sqlite-dev libpcap-dev jpeg-dev dos2unix libev-dev build-base linux-headers python3 python3-dev py3-pip \
    && apk cache clean 

# 创建虚拟环境并激活
RUN python3 -m venv /www/server/panel/pyenv
ENV PATH="/www/server/panel/pyenv/bin:$PATH"

# 确保虚拟环境中的python和pip具有执行权限
RUN chmod +x /www/server/panel/pyenv/bin/python3 \
    && chmod +x /www/server/panel/pyenv/bin/pip3
    
# 安装Python和pip包
RUN pip install --upgrade pip \
    && pip install Pillow psutil pyinotify pycryptodome upyun oss2 pymysql qrcode qiniu redis pymongo Cython configparser cos-python-sdk-v5 supervisor gevent gevent-websocket pyopenssl \
    && pip install flask==1.1.4 \
    && pip install Pillow -U

# 创建符号链接
RUN ln -sf /www/server/panel/pyenv/bin/pip3 /usr/bin/btpip \
    && ln -sf /www/server/panel/pyenv/bin/python3 /usr/bin/btpython


# 复制脚本
COPY ["bt.sh", "init_mysql.sh", "install_panel.sh", "/"]

# 转换启动脚本
RUN dos2unix /bt.sh && dos2unix /init_mysql.sh && dos2unix /install_panel.sh

# 下载并安装宝塔面板及 lnmp 环境
RUN echo y | bash /install_panel.sh -P 8888 --ssl-disable \
    && rm -rf /www/server/data/* \
    && echo "docker_bt_alpine" > /www/server/panel/data/o.pl \
    && echo '["memuA", "memuAsite", "memuAdatabase", "memuAcontrol", "memuAfiles", "memuAlogs", "memuAxterm", "memuAcrontab", "memuAsoft", "memuAconfig", "dologin", "memu_btwaf", "memuAssl"]' > /www/server/panel/config/show_menu.json \
    && apk cache clean \
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
HEALTHCHECK --interval=5s --timeout=3s CMD prot="http"; if [ -f "/www/server/panel/data/ssl.pl" ]; then prot="https"; fi; curl -k -i $prot://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1