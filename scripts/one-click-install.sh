#!/usr/bin/env bash
set -Eeuo pipefail
read -r -p '目录 [/opt/9router-official]: ' d </dev/tty; d=${d:-/opt/9router-official}; git clone https://github.com/decolua/9router.git "$d"; cd "$d"; docker compose up -d
