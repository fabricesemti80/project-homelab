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

"${docker_root}/scripts/render-secrets.sh"

exec docker compose --project-directory "$docker_root" -f "$compose_file" up -d --remove-orphans
