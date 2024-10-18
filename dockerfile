#2024.7.28 修改 自动获取最新下载链接，使用通配符*匹配最新程序目录（有更新时，直接点Factory rebuild，即可获取最新的文件更新）
# 使用官方Ubuntu基础镜像
FROM ubuntu:latest

# 安装curl、unzip、jq和sed（用于编辑文件和解析JSON）
RUN apt-get update && \
    apt-get install -y curl unzip jq sed

# 设置工作目录
WORKDIR /app

# 使用GitHub API获取最新版本的下载链接
RUN curl -L $(curl -s https://api.github.com/repos/wozulong/fuclaude/releases/latest | \
                 jq -r '.assets[] | select(.name | contains("linux-amd64")) | .browser_download_url') -o fuclaude.zip && \
    unzip -P linux.do fuclaude.zip && \
    rm fuclaude.zip

# 进入程序目录
WORKDIR /app
RUN mv fuclaude-* fuclaude
WORKDIR /app/fuclaude

# 修改文件权限，确保可读可写
RUN chmod 666 config.json

# 修改配置文件
RUN sed -i 's/127.0.0.1/0.0.0.0/' config.json && \
    sed -i 's/"signup_enabled": false/"signup_enabled": true/' config.json && \
    sed -i 's/"show_session_key": false/"show_session_key": true/' config.json

# 确保程序文件可执行
RUN chmod +x fuclaude 

# 暴露端口8181
EXPOSE 8181

# 运行程序
CMD ["./fuclaude"]
