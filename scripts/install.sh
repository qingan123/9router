#!/usr/bin/env bash
set -Eeuo pipefail
APP_DIR_BASE=${APP_DIR_BASE:-${APP_DIR:-/opt/9router}}; PORT=${PORT:-20128}; REPO_URL=${REPO_URL:-https://github.com/qingan123/9router.git}
fail(){ echo "ERROR: $*" >&2; exit 1; }
read_tty(){ local v; IFS= read -r -p "$1" v </dev/tty || fail '需要交互终端'; printf '%s' "$v"; }
[[ $EUID -eq 0 ]] || fail '请使用 root/sudo'; command -v git >/dev/null || fail '缺少 git'; command -v docker >/dev/null || fail '缺少 docker'; docker compose version >/dev/null || fail '需要 Docker Compose v2'
PORT=$(read_tty "端口 [$PORT]: "); PORT=${PORT:-20128}; [[ $PORT =~ ^[0-9]+$ ]] || fail '端口无效'
APP_DIR="$APP_DIR_BASE"; [[ "$PORT" == 20128 ]] || APP_DIR="${APP_DIR_BASE}-${PORT}"
printf '安装目录自动设置为: %s\n' "$APP_DIR"
if command -v ss >/dev/null 2>&1; then
  for candidate in "$PORT" 8787; do
    ss -ltn "sport = :$candidate" | grep -q LISTEN && fail "端口 $candidate 已被占用"
  done
fi
mkdir -p "$APP_DIR"; [[ -z "$(find "$APP_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]] || fail '目标目录非空'; git clone --depth 1 "$REPO_URL" "$APP_DIR"; cd "$APP_DIR"
printf 'PORT=%s\n' "$PORT" > .env
sed -i -E "s/\"[0-9]+:20128\"/\"$PORT:20128\"/" docker-compose.yml
docker compose --env-file .env up -d --build
for _ in {1..60}; do curl -fsS --max-time 2 "http://127.0.0.1:$PORT/api/health" >/dev/null && break; sleep 1; done
curl -fsS --max-time 2 "http://127.0.0.1:$PORT/api/health" >/dev/null || { docker compose logs --tail=100; exit 1; }
ip="${PUBLIC_HOST:-$(curl -4fsS --max-time 5 https://api.ipify.org || true)}"; url=${ip:+http://$ip:$PORT/dashboard}; [[ -n "$url" ]] || url='公网IP探测失败，请检查安全组/UFW'
printf '部署完成。\n公网控制台: %s\n本机控制台: http://127.0.0.1:%s/dashboard\n端口: %s（默认发布到公网）\n目录: %s\n' "$url" "$PORT" "$PORT" "$APP_DIR"
