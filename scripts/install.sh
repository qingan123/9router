#!/usr/bin/env bash
set -Eeuo pipefail
read -r -p '目录 [/opt/9router]: ' d </dev/tty; d=${d:-/opt/9router}; read -r -p '端口 [20128]: ' p </dev/tty; p=${p:-20128}; git clone https://github.com/qingan123/9router.git "$d"; cd "$d"; printf 'PORT=%s\n' "$p" > .env; docker compose up -d --build
