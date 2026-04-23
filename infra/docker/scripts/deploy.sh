#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

docker_root="${repo_root}/infra/docker"
compose_file="${docker_root}/docker-compose.yml"

"${docker_root}/scripts/render-secrets.sh"

exec docker compose --project-directory "$docker_root" -f "$compose_file" up -d --remove-orphans
