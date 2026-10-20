#!/usr/bin/env bash
set -e

IMAGE=localhost:5000/vue-cicd-test/app
TAG=${1:?用法: sh deploy.sh <版本号> [端口]}
PORT=${2:-8082}

# 8082 是"蓝"（正常线上），8089 是"绿"（灰度用）
if [ "$PORT" = "8082" ]; then NAME=vue-app; else NAME=vue-app-green; fi

echo "▶ 开始部署版本 $TAG 到端口 $PORT"

docker pull "$IMAGE:$TAG"

OLD=""
if docker ps -a --format '{{.Names}}' | grep -qx "$NAME"; then
  OLD=$(docker inspect -f '{{index .Config.Labels "app.version"}}' "$NAME" 2>/dev/null || echo "")
  echo "▶ 该端口当前版本：${OLD:-未知}，先移除旧容器"
  docker rm -f "$NAME" >/dev/null
fi

docker run -d --name "$NAME" -p "$PORT:80" \
  -e APP_ENV=production \
  -e BUILD_VERSION="$TAG" \
  --label app.version="$TAG" \
  --restart=on-failure:3 \
  "$IMAGE:$TAG"

echo "▶ 等待健康检查通过..."
for i in $(seq 1 20); do
  STATUS=$(docker inspect -f '{{.State.Health.Status}}' "$NAME" 2>/dev/null || echo none)
  if [ "$STATUS" = "healthy" ]; then
    echo "✅ 部署成功：http://localhost:$PORT （版本 $TAG）"
    exit 0
  fi
  sleep 2
done

echo "❌ 应用 40 秒没起来，自动清理"
docker rm -f "$NAME" >/dev/null || true
if [ -n "$OLD" ]; then
  echo "▶ 回滚到 $OLD"
  docker run -d --name "$NAME" -p "$PORT:80" -e BUILD_VERSION="$OLD" \
    --label app.version="$OLD" "$IMAGE:$OLD" >/dev/null
  echo "✅ 已回滚：http://localhost:$PORT （版本 $OLD）"
fi
exit 1