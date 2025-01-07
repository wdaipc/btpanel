FROM docker.cnb.cool/btpanel/btpanel:9.0_lts_fresh
    
# 安装 lib 库
RUN curl -o /www/server/panel/install/lib.sh https://dg2.bt.cn/install/1/lib.sh  \
    && sh /www/server/panel/install/lib.sh \
    && chmod +x /bt.sh \
    && chmod +x /init_mysql.sh
    
ENTRYPOINT ["/bin/sh","-c","/bt.sh"]

# 暴漏特定端口
EXPOSE 22 80 443 888 3306 8888

# 健康检查
HEALTHCHECK --interval=5s --timeout=3s CMD prot="http"; if [ -f "/www/server/panel/data/ssl.pl" ]; then prot="https"; fi; curl -k -i $prot://127.0.0.1:$(cat /www/server/panel/data/port.pl)$(cat /www/server/panel/data/admin_path.pl) | grep -E '(200|404)' || exit 1