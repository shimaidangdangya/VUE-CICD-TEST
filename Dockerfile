# 第一段：负责"打包"，用完就扔
FROM node:22-alpine AS builder
WORKDIR /app

# 这个基础镜像里没有 pnpm，先装（走国内源）
RUN npm config set registry https://registry.npmmirror.com \
 && npm install -g pnpm@12.14.0 --registry=https://registry.npmmirror.com

# 只复制"依赖清单"两个文件：包没变的时候，这一层直接用缓存，不重装
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# 再复制源码（源码改了只影响后面这两层）
COPY . .
RUN pnpm run build

# 第二段：真正要发布的镜像，只装 nginx + 打包结果
FROM nginx:1.27-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/dist/ /usr/share/nginx/html/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
COPY deploy/env.sh /docker-entrypoint.d/40-env.sh
RUN chmod +x /docker-entrypoint.d/40-env.sh
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ >/dev/null || exit 1