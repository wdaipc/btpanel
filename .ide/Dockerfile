# 此文件为远程开发环境配置文件
FROM debian:bookworm

RUN apt update &&\
    apt install -y wget rsync unzip openssh-server vim lsof git git-lfs locales locales-all libgit2-1.5 libgit2-dev net-tools jq curl &&\
    rm -rf /var/lib/apt/lists/*

# install code-server
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN code-server --install-extension dbaeumer.vscode-eslint &&\
    code-server --install-extension pinage404.git-extension-pack &&\
    code-server --install-extension redhat.vscode-yaml &&\
    code-server --install-extension esbenp.prettier-vscode &&\
    code-server --install-extension eamodio.gitlens &&\
    code-server --install-extension mhutchie.git-graph &&\
    code-server --install-extension ms-azuretools.vscode-docker &&\
    code-server --install-extension PKief.material-icon-theme &&\
    code-server --install-extension tencent-cloud.coding-copilot &&\
    echo done

ENV LC_ALL zh_CN.UTF-8
ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8