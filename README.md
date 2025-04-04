> 此 Docker 镜像由宝塔面板官方发布，镜像版本为宝塔面板 9.3.0 正式版和 9.0.0_lts 稳定版，镜像会随着宝塔面板更新，目前支持`x86_64`和`arm64`架构。

![badge](https://cnb.cool/btpanel/btpanel/-/badge/git/latest/ci/git-clone-yyds)
![badge](https://cnb.cool/btpanel/btpanel/-/badge/git/latest/ci/pipeline-as-code)
![badge](https://cnb.cool/btpanel/btpanel/-/badge/git/latest/ci/status/push)

## 使用方法
> 以下命令中的镜像默认使用 CNB 仓库镜像，如需直接从 DockerHub 拉取，请替换镜像地址，如将`docker.cnb.cool/btpanel/btpanel:latest`替换为`btpanel:baota:latest`

### Docker Run
- 复制下方的命令，无需映射端口使用本地网络直接部署宝塔面板docker镜像
```bash
docker run -d --restart unless-stopped --name baota --net=host -v ~/www:/www docker.cnb.cool/btpanel/btpanel:latest
```
- 复制下方的命令，映射指定端口部署宝塔面板docker镜像
```bash
docker run -d --restart unless-stopped --name baota -p 8888:8888 -p 22:22 -p 443:443 -p 80:80 -p 888:888 -v ~/www:/www docker.cnb.cool/btpanel/btpanel:latest
```

### Docker Compose
```yml
services:
  btpanel:
    image: docker.cnb.cool/btpanel/btpanel:latest # 宝塔面板官方镜像（国内源），也可直接使用dockerhub镜像 btpanel/baota:latest
    deploy:
      resources:
        limits:
          cpus: "2.0"  # 最大CPU核心限制，根据实际情况调整
          memory: "1024M"  # 最大内存限制，根据实际情况调整
      restart_policy:
        condition: always
    ports:
      - "38888:8888" # 宝塔面板对外访问端口，默认38888
      - "8080:80" # Web服务端口，默认8080
      - "8443:443" # HTTPS服务端口，默认8443
      - "33306:3306" # MySQL服务端口，默认33306，不需要暴露到容器外可删除
      - "22022:22" # SSH服务端口，默认22022，不需要暴露到容器外可删除
      - "32888:888" # PHPMyAdmin服务端口，默认32888，不需要暴露到容器外可删除
    volumes:
      - "/www:/www" # 持久化存储宝塔面板数据，默认/www，可根据实际情况调整目录
    labels:
      createdBy: "bt_apps"
```
## 如果面板需要使用Docker
参考格式  本地docker环境挂载进面板docker使用
```yml
- "/usr/bin/docker:/usr/bin/docker"
- "/run/docker.sock:/run/docker.sock"
```

## 镜像说明
除标注了`9.0_lts`稳定版的标签外，其他镜像均为`9.3.0/9.2.0`正式版
- `latest`：基于`Debian12`镜像打包，安装了宝塔面板和后续安装环境所用的依赖。
- `nas`：基于`Debian12`镜像打包，安装了宝塔面板和`Nginx 1.27`(amd架构)或`Nginx openresty`(arm64架构)
- `9.0_lts_fresh`：基于`Debian12`镜像打包，安装了宝塔面板稳定版。
- `9.0_lts_lib`：基于`Debian12`镜像打包，安装了宝塔面板稳定版和和后续安装环境所用的依赖。
- `slim`：基于`debian:bookworm-slim`镜像打包，仅安装了宝塔面板，体积较小。

