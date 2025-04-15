FROM ghcr.io/open-webui/open-webui:main

# 更新包列表并安装 Redis 和 Python 依赖
RUN apt-get update && \
    apt-get install -y redis-server
    # 清理 apt 缓存减少镜像体积
    # rm -rf /var/lib/apt/lists/* && \
    # 安装/升级unstructured库并包含xlsx处理所需的额外依赖
    # 使用 --no-cache-dir 减少镜像体积
    # pip install --no-cache-dir --upgrade "unstructured[xlsx]"

# # 配置 NLTK 数据下载目录
# # 设置环境变量，让 NLTK 将数据下载到指定目录
# # 使用 /data 目录通常是 HF Spaces 推荐的持久化存储位置
# # 如果不需要持久化 NLTK 数据，也可以用 /tmp/nltk_data 或 /app/nltk_data
ENV NLTK_DATA=/data/nltk_data
# # 创建 NLTK 数据目录，并设置为任何用户都可写 (777)
# # 这样无论 HF Spaces 最终以哪个非 root 用户运行，都能写入
RUN mkdir -p ${NLTK_DATA} && chmod 777 ${NLTK_DATA}

#-------------------------------------
# 修改Redis配置和权限
RUN mkdir -p /var/run/redis && \
   chown -R 1000:1000 /var/run/redis && \
   chown -R 1000:1000 /var/lib/redis && \
   chmod 777 /var/run/redis

# 创建启动Redis的脚本
RUN echo "#!/bin/bash" > redis-start.sh && \
   echo "redis-server --daemonize yes --save '' --appendonly no" >> redis-start.sh && \
   echo "sleep 2" >> redis-start.sh && \
   echo "echo 'Redis status:'" >> redis-start.sh && \
   echo "redis-cli ping" >> redis-start.sh

COPY sync_data.sh sync_data.sh

RUN chmod -R 777 ./data && \
    chmod -R 777 ./open_webui && \
    sed -i "1r sync_data.sh" ./start.sh  && \
    sed -i "1r redis-start.sh" ./start.sh
