#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

if [ -f "${repo_root}/.envrc" ]; then
  set -a
  # shellcheck disable=SC1091
  . "${repo_root}/.envrc"
  set +a
fi

docker_root="${repo_root}/infra/docker"
compose_file="${docker_root}/docker-compose.yml"
remote_host="${HOMELAB_DOCKER_HOST:-}"
remote_dir="${HOMELAB_DOCKER_REMOTE_DIR:-/opt/project-homelab/infra/docker}"
remote_compose="${HOMELAB_DOCKER_REMOTE_COMPOSE:-sudo docker compose}"

if [ -n "$remote_host" ]; then
  export HOMELAB_DOCKER_ROOT="$remote_dir"
fi

"${docker_root}/scripts/render-secrets.sh"

if [ -z "$remote_host" ]; then
  exec docker compose --project-directory "$docker_root" -f "$compose_file" up -d --remove-orphans
fi

remote_parent="$(dirname "$remote_dir")"
remote_base="$(basename "$remote_dir")"

ssh "$remote_host" "mkdir -p '$remote_dir' 2>/dev/null || { sudo mkdir -p '$remote_dir' && sudo chown -R \"\$(id -u):\$(id -g)\" '$remote_parent'; }"

tar -C "$docker_root" \
  --exclude '.DS_Store' \
  -cz . | ssh "$remote_host" "tar -xzf - -C '$remote_dir' && cd '$remote_dir' && $remote_compose -f docker-compose.yml up -d --remove-orphans"
