cat > /usr/share/nginx/html/config.js <<EOF
window.__APP_CONFIG__ = {
  API_BASE_URL: '${API_BASE_URL:-/api}',
  APP_ENV: '${APP_ENV:-production}',
  BUILD_VERSION: '${BUILD_VERSION:-unknown}',
};
EOF
echo "config.js 已生成"