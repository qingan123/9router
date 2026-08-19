#!/usr/bin/env bash
set -Eeuo pipefail
APP_DIR=${APP_DIR:-}; PORT=${PORT:-}
rows(){ for d in /opt/* /root/*; do [[ -d "$d/.git" && -f "$d/docker-compose.yml" ]] || continue; git -C "$d" remote -v 2>/dev/null|grep -qi 9router || continue; p=$(grep -oE '[0-9]+:20128' "$d/docker-compose.yml"|head -1|cut -d: -f1); v=$(git -C "$d" rev-parse --short HEAD); printf '9router\t%s\t%s\t%s\n' "${p:-unknown}" "$v" "$d"; done; }
if [[ -z "$APP_DIR" ]]; then [[ -t 0 ]] || { echo '非交互模式需APP_DIR和PORT' >&2; exit 1; }; mapfile -t a < <(rows); ((${#a[@]})) || exit 1; echo '编号 项目名称 端口 当前版本 项目目录'; printf '%s\n' "${a[@]}"|awk -F '\t' '{printf "%d) %s %s %s %s\n",NR,$1,$2,$3,$4}'; read -r -p '选择编号或端口: ' c </dev/tty; row=$(printf '%s\n' "${a[@]}"|awk -F '\t' -v c="$c" 'NR==c||$2==c{print;exit}'); [[ -n "$row" ]] || exit 1; PORT=$(echo "$row"|cut -f2); APP_DIR=$(echo "$row"|cut -f4); fi
cd "$APP_DIR"; [[ -z "$(git status --porcelain)" ]] || exit 1; git pull --ff-only; docker compose up -d --build
