#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

env_remote_host="${HOMELAB_DOCKER_HOST:-}"
env_remote_dir="${HOMELAB_DOCKER_REMOTE_DIR:-}"
env_remote_compose="${HOMELAB_DOCKER_REMOTE_COMPOSE:-}"

if [ -f "${repo_root}/.envrc" ]; then
  set -a
  # shellcheck disable=SC1091
  . "${repo_root}/.envrc"
  set +a
fi

[ -z "$env_remote_host" ] || HOMELAB_DOCKER_HOST="$env_remote_host"
[ -z "$env_remote_dir" ] || HOMELAB_DOCKER_REMOTE_DIR="$env_remote_dir"
[ -z "$env_remote_compose" ] || HOMELAB_DOCKER_REMOTE_COMPOSE="$env_remote_compose"

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
# shellcheck disable=SC2034
remote_base="$(basename "$remote_dir")"

# shellcheck disable=SC2029
ssh "$remote_host" "mkdir -p '$remote_dir' 2>/dev/null || { sudo mkdir -p '$remote_dir' && sudo chown -R \"\$(id -u):\$(id -g)\" '$remote_parent'; }"

# Sync all docker service definitions
rsync -avz --exclude '.DS_Store' --exclude '._*' --exclude 'runtime' --exclude 'secrets' \
  "$docker_root/" "$remote_host:$remote_dir/"

# Sync runtime files without deleting the parent directory (which breaks bind mounts)
rsync -avz --delete --exclude '.DS_Store' --exclude '._*' \
  "$docker_root/runtime/" "$remote_host:$remote_dir/runtime/"

# shellcheck disable=SC2029
ssh "$remote_host" "sudo rsync -avz --no-perms --no-owner --no-group '$remote_dir/runtime/' /opt/project-homelab/infra/docker/runtime/"

# Start stack; use --force-recreate to ensure stale bind mounts are refreshed if runtime was wiped
# shellcheck disable=SC2029
ssh "$remote_host" "cd '$remote_dir' && $remote_compose -f docker-compose.yml up -d --remove-orphans --force-recreate"
