#!/usr/bin/env bash
set -Eeuo pipefail
export REPO_URL=${REPO_URL:-https://github.com/decolua/9router.git}
export APP_DIR=${APP_DIR:-/opt/9router-official}
exec bash "$(dirname "$0")/install.sh"
