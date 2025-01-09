> 此 Docker 镜像由宝塔面板官方发布，镜像版本为宝塔面板 9.3.0 正式版和 9.0.0_lts 稳定版，镜像会随着宝塔面板更新，目前支持`x86_64`和`arm64`架构。
## 使用方法
> 以下命令中的镜像默认使用 CNB 仓库镜像，如需直接从 DockerHub 拉取，请替换镜像地址，如将`docker.cnb.cool/btpanel/btpanel:latest`替换为`btpanel:baota:latest`
- 复制下方的命令，无需映射端口使用本地网络直接部署宝塔面板docker镜像
```bash
docker run -d --restart unless-stopped --name baota --net=host -v ~/website_data:/www/wwwroot -v ~/mysql_data:/www/server/data -v /vhost:/www/server/panel/vhost docker.cnb.cool/btpanel/btpanel:latest
```
- 复制下方的命令，映射指定端口部署宝塔面板docker镜像
```bash
docker run -d --restart unless-stopped --name baota -p 8888:8888 -p 22:22 -p 443:443 -p 80:80 -p 888:888 -v ~/website_data:/www/wwwroot -v ~/mysql_data:/www/server/data -v ~/vhost:/www/server/panel/vhost docker.cnb.cool/btpanel/btpanel:latest
```

## 镜像说明
除标注了`9.0_lts`稳定版的标签外，其他镜像均为`9.3.0/9.2.0`正式版
- `latest`：基于`Debian12`镜像打包，安装了宝塔面板和后续安装环境所用的依赖。
- `nas`：基于`Debian12`镜像打包，安装了宝塔面板和`Nginx 1.27`(amd架构)或`Nginx openresty`(arm64架构)
- `9.0_lts_fresh`：基于`Debian12`镜像打包，安装了宝塔面板稳定版。
- `9.0_lts_lib`：基于`Debian12`镜像打包，安装了宝塔面板稳定版和和后续安装环境所用的依赖。
- `slim`：基于`debian:bookworm-slim`镜像打包，仅安装了宝塔面板，体积较小。

