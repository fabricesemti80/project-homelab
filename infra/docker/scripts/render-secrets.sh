#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
docker_root="${repo_root}/infra/docker"

if [ -f "${repo_root}/.envrc" ]; then
  set -a
  # shellcheck disable=SC1091
  . "${repo_root}/.envrc"
  set +a
fi

required_vars=(
  TAILSCALE_AUTH_KEY
  CLOUDFLARED_TUNNEL_TOKEN
  OMNI_CA_CERT_PEM
  OMNI_TLS_CERT_PEM
  OMNI_TLS_KEY_PEM
  OMNI_GPG_KEY_ASC
  OMNI_DEX_PASSWORD_HASH
  OMNI_DEX_CLIENT_SECRET
  OMNI_USER_EMAIL
  ARCANE_ENCRYPTION_KEY
  ARCANE_JWT_SECRET
)

for var in "${required_vars[@]}"; do
  # Optional vars
  if [[ $var == "TAILSCALE_AUTH_KEY" || $var == "CLOUDFLARED_TUNNEL_TOKEN" ]]; then
    continue
  fi
  if [ -z "${!var:-}" ]; then
    printf '%s is not set; define it in .envrc before rendering Docker runtime secrets\n' "$var" >&2
    exit 1
  fi
done

omni_host="${OMNI_ENDPOINT:-omni.krapulax.dev}"
omni_auth_host="${OMNI_AUTH_ENDPOINT:-auth.krapulax.dev}"
omni_advertised_api_url="${OMNI_ADVERTISED_API_URL:-https://${omni_host}/}"
omni_auth_provider_url="${OMNI_AUTH_PROVIDER_URL:-https://${omni_auth_host}}"
omni_dex_username="${OMNI_DEX_USERNAME:-admin}"

dotenv_quote() {
  printf "'"
  printf '%s' "$1" | sed "s/'/'\\''/g"
  printf "'"
}

write_dotenv() {
  local env_file="${docker_root}/.env"
  local docker_root_value="${HOMELAB_DOCKER_ROOT:-}"
  if [ -z "$docker_root_value" ]; then
    docker_root_value="$docker_root"
  fi
  {
    printf 'COMPOSE_PROJECT_NAME=%s\n' "$(dotenv_quote "${COMPOSE_PROJECT_NAME:-homelab}")"
    printf 'HOMELAB_DOCKER_ROOT=%s\n' "$(dotenv_quote "$docker_root_value")"
    printf 'HOMELAB_DOCKER_PLATFORM=%s\n' "$(dotenv_quote "${HOMELAB_DOCKER_PLATFORM:-linux/amd64}")"
    [ -z "${COMPOSE_PROFILES:-}" ] || printf 'COMPOSE_PROFILES=%s\n' "$(dotenv_quote "$COMPOSE_PROFILES")"
    printf 'PUID=%s\n' "$(dotenv_quote "${PUID:-1000}")"
    printf 'PGID=%s\n' "$(dotenv_quote "${PGID:-1000}")"
    printf 'TRAEFIK_CLOUDFLARE_API_TOKEN=%s\n' "$(dotenv_quote "${TRAEFIK_CLOUDFLARE_API_TOKEN:-}")"
    printf 'TRAEFIK_CLOUDFLARE_ZONE_ID=%s\n' "$(dotenv_quote "${TRAEFIK_CLOUDFLARE_ZONE_ID:-}")"
    printf 'TRAEFIK_CLOUDFLARE_EMAIL=%s\n' "$(dotenv_quote "${TRAEFIK_CLOUDFLARE_EMAIL:-}")"
    printf 'TRAEFIK_LOG_LEVEL=%s\n' "$(dotenv_quote "${TRAEFIK_LOG_LEVEL:-DEBUG}")"
    printf 'ARCANE_HOSTNAME=%s\n' "$(dotenv_quote "${ARCANE_HOSTNAME:-arcane.krapulax.dev}")"
    printf 'ARCANE_APP_URL=%s\n' "$(dotenv_quote "${ARCANE_APP_URL:-https://arcane.krapulax.dev}")"
    printf 'ARCANE_ENCRYPTION_KEY=%s\n' "$(dotenv_quote "$ARCANE_ENCRYPTION_KEY")"
    printf 'ARCANE_JWT_SECRET=%s\n' "$(dotenv_quote "$ARCANE_JWT_SECRET")"
    printf 'BESZEL_HOSTNAME=%s\n' "$(dotenv_quote "${BESZEL_HOSTNAME:-beszel.krapulax.dev}")"
    printf 'BESZEL_APP_URL=%s\n' "$(dotenv_quote "${BESZEL_APP_URL:-https://beszel.krapulax.dev}")"
    printf 'BESZEL_AGENT_HUB_URL=%s\n' "$(dotenv_quote "${BESZEL_AGENT_HUB_URL:-http://localhost:8090}")"
    printf 'BESZEL_AGENT_KEY=%s\n' "$(dotenv_quote "${BESZEL_AGENT_KEY:-}")"
    printf 'BESZEL_AGENT_TOKEN=%s\n' "$(dotenv_quote "${BESZEL_AGENT_TOKEN:-}")"
    printf 'WHOAMI_HOSTNAME=%s\n' "$(dotenv_quote "${WHOAMI_HOSTNAME:-whoami.krapulax.dev}")"
    printf 'OMNI_IMAGE=%s\n' "$(dotenv_quote "${OMNI_IMAGE:-ghcr.io/siderolabs/omni:latest}")"
    printf 'OMNI_NAME=%s\n' "$(dotenv_quote "${OMNI_NAME:-trinity}")"
    printf 'OMNI_ENDPOINT=%s\n' "$(dotenv_quote "$omni_host")"
    printf 'OMNI_AUTH_ENDPOINT=%s\n' "$(dotenv_quote "$omni_auth_host")"
    printf 'OMNI_BIND_ADDR=%s\n' "$(dotenv_quote "${OMNI_BIND_ADDR:-0.0.0.0:8443}")"
    printf 'OMNI_MACHINE_API_BIND_ADDR=%s\n' "$(dotenv_quote "${OMNI_MACHINE_API_BIND_ADDR:-0.0.0.0:8095}")"
    printf 'OMNI_MACHINE_API_ADVERTISED_URL=%s\n' "$(dotenv_quote "${OMNI_MACHINE_API_ADVERTISED_URL:-https://${omni_host}:8095/}")"
    printf 'OMNI_ADVERTISED_API_URL=%s\n' "$(dotenv_quote "$omni_advertised_api_url")"
    printf 'OMNI_KUBERNETES_PROXY_BIND_ADDR=%s\n' "$(dotenv_quote "${OMNI_KUBERNETES_PROXY_BIND_ADDR:-0.0.0.0:8100}")"
    printf 'OMNI_ADVERTISED_KUBERNETES_PROXY_URL=%s\n' "$(dotenv_quote "${OMNI_ADVERTISED_KUBERNETES_PROXY_URL:-https://${omni_host}:8100/}")"
    printf 'OMNI_EVENT_SINK_PORT=%s\n' "$(dotenv_quote "${OMNI_EVENT_SINK_PORT:-8091}")"
    printf 'OMNI_DEX_CLIENT_SECRET=%s\n' "$(dotenv_quote "${OMNI_DEX_CLIENT_SECRET:-}")"
    printf 'OMNI_SIDEROLINK_WIREGUARD_BIND_ADDR=%s\n' "$(dotenv_quote "${OMNI_SIDEROLINK_WIREGUARD_BIND_ADDR:-0.0.0.0:50180}")"
    printf 'OMNI_SIDEROLINK_WIREGUARD_ADVERTISED_ADDR=%s\n' "$(dotenv_quote "${OMNI_SIDEROLINK_WIREGUARD_ADVERTISED_ADDR:-omni.krapulax.dev:50180}")"
    printf 'OMNI_AUTH_PROVIDER_URL=%s\n' "$(dotenv_quote "$omni_auth_provider_url")"
    printf 'OMNI_USER_EMAIL=%s\n' "$(dotenv_quote "$OMNI_USER_EMAIL")"
  } >"$env_file"
  chmod 0600 "$env_file"
}
tailscale_dir="${docker_root}/runtime/secrets/tailscale"
cloudflared_dir="${docker_root}/runtime/secrets/cloudflared"
omni_dir="${docker_root}/runtime/secrets/omni"
traefik_dynamic_dir="${docker_root}/runtime/traefik/dynamic"

mkdir -p "$tailscale_dir" "$cloudflared_dir" "$omni_dir" "$traefik_dynamic_dir"
chmod 700 "${docker_root}/runtime" "${docker_root}/runtime/secrets" "$tailscale_dir" "$cloudflared_dir" "$omni_dir"

if [ -n "${TAILSCALE_AUTH_KEY:-}" ]; then
  printf '%s\n' "$TAILSCALE_AUTH_KEY" >"${tailscale_dir}/auth_key"
  chmod 0600 "${tailscale_dir}/auth_key"
fi

if [ -n "${CLOUDFLARED_TUNNEL_TOKEN:-}" ]; then
  secret_file="$(mktemp)"
  trap 'rm -f "$secret_file"' EXIT
  printf '%s\n' "$CLOUDFLARED_TUNNEL_TOKEN" >"$secret_file"

  if jq -e 'type == "object" and has("AccountTag") and has("TunnelSecret") and has("TunnelID")' "$secret_file" >/dev/null 2>&1; then
    tunnel_id="$(jq -r '.TunnelID' "$secret_file")"
    printf '%s\n' \
      "tunnel: ${tunnel_id}" \
      "credentials-file: /etc/cloudflared/credentials.json" \
      "ingress:" \
      "  - service: http://127.0.0.1:80" \
      >"${cloudflared_dir}/config.yml"
    install -m 0600 "$secret_file" "${cloudflared_dir}/credentials.json"
  else
    printf '%s\n' \
      "ingress:" \
      "  - service: http://127.0.0.1:80" \
      >"${cloudflared_dir}/config.yml"
    install -m 0600 "$secret_file" "${cloudflared_dir}/token"
  fi
  chmod 0600 "${cloudflared_dir}/config.yml"
fi

printf '%s\n' "$OMNI_CA_CERT_PEM" >"${omni_dir}/ca.pem"
printf '%s\n%s\n' "$OMNI_TLS_CERT_PEM" "$OMNI_CA_CERT_PEM" >"${omni_dir}/server-chain.pem"
printf '%s\n' "$OMNI_TLS_KEY_PEM" >"${omni_dir}/server-key.pem"
printf '%s\n' "$OMNI_GPG_KEY_ASC" >"${omni_dir}/omni.asc"

# Create a full cert chain with server cert + all CAs for TLS verification
# This allows Omni to trust certificates issued by our CA
printf '%s\n%s\n' "$OMNI_TLS_CERT_PEM" "$OMNI_CA_CERT_PEM" >"${omni_dir}/full-chain.pem"

issuer_json="$(printf '%s' "$omni_auth_provider_url" | jq -Rs .)"
redirect_json="$(printf '%s' "${omni_advertised_api_url%/}/oidc/consume" | jq -Rs .)"
client_secret_json="$(printf '%s' "$OMNI_DEX_CLIENT_SECRET" | jq -Rs .)"
email_json="$(printf '%s' "$OMNI_USER_EMAIL" | jq -Rs .)"
username_json="$(printf '%s' "$omni_dex_username" | jq -Rs .)"
password_hash_json="$(printf '%s' "$OMNI_DEX_PASSWORD_HASH" | jq -Rs .)"

printf '%s\n' \
  "issuer: ${issuer_json}" \
  "storage:" \
  "  type: memory" \
  "web:" \
  "  https: 0.0.0.0:5556" \
  "  tlsCert: /etc/dex/tls/server-chain.pem" \
  "  tlsKey: /etc/dex/tls/server-key.pem" \
  "staticClients:" \
  "  - name: Omni" \
  "    id: omni" \
  "    secret: ${client_secret_json}" \
  "    redirectURIs:" \
  "      - ${redirect_json}" \
  "enablePasswordDB: true" \
  "staticPasswords:" \
  "  - email: ${email_json}" \
  "    username: ${username_json}" \
  "    preferredUsername: ${username_json}" \
  "    hash: ${password_hash_json}" \
  >"${omni_dir}/dex.yaml"

# Empty omni config - all configuration via command flags
echo "" >"${omni_dir}/omni.yaml"

chmod 0644 "${omni_dir}/ca.pem" "${omni_dir}/server-chain.pem"
chmod 0600 "${omni_dir}/server-key.pem" "${omni_dir}/omni.asc" "${omni_dir}/dex.yaml" "${omni_dir}/omni.yaml"

cat >"${traefik_dynamic_dir}/omni.yml" <<YAML
http:
  routers:
    omni:
      rule: Host(\`${omni_host}\`)
      entryPoints:
        - web
      service: omni
    omni-secure:
      rule: Host(\`${omni_host}\`)
      entryPoints:
        - websecure
      service: omni
    omni-auth:
      rule: Host(\`${omni_auth_host}\`)
      entryPoints:
        - web
      service: omni-auth
    omni-auth-secure:
      rule: Host(\`${omni_auth_host}\`)
      entryPoints:
        - websecure
      service: omni-auth
  services:
    omni:
      loadBalancer:
        serversTransport: omni-insecure
        servers:
          - url: https://omni:8443
    omni-auth:
      loadBalancer:
        serversTransport: omni-insecure
        servers:
          - url: https://dex:5556
  serversTransports:
    omni-insecure:
      insecureSkipVerify: true
YAML
chmod 0644 "${traefik_dynamic_dir}/omni.yml"

write_dotenv
printf 'Rendered Docker runtime secrets under %s/runtime and %s/.env\n' "$docker_root" "$docker_root"
