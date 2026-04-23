# Docker Deployment

This directory owns the Docker deployment for services that used to be declared as NixOS `oci-containers` on `trinity`.
It is intentionally plain Docker Compose so it can run on non-Nix machines.

## Layout

-   `docker-compose.yml`: main Compose entrypoint. It includes each service-specific Compose file.
-   `arcane/`, `beszel/`, `cloudflared/`, `traefik/`, `uptime-kuma/`, `whoami/`: one directory per service group.
-   `scripts/render-secrets.sh`: renders ignored runtime files from Doppler-injected environment variables.
-   `scripts/deploy.sh`: renders runtime files and starts the local Docker Compose stack.
-   `runtime/`: generated config and secret mounts consumed by Compose. Ignored by Git.
-   `secrets/`: local source secret material. Ignored by Git.

## Required Secrets

The Docker tasks now expect their runtime values to be injected from Doppler:

-   project: `project-homelab`
-   config: `dev_homelab`

The key values used by the Docker stack include:

-   `DOMAIN`
-   `CLOUDFLARED_TUNNEL_TOKEN`
-   `TRAEFIK_CLOUDFLARE_API_TOKEN`, `TRAEFIK_CLOUDFLARE_ZONE_ID`, `TRAEFIK_CLOUDFLARE_EMAIL`
-   `ARCANE_ENCRYPTION_KEY`, `ARCANE_JWT_SECRET`

Per-service values such as `ARCANE_HOSTNAME` or `BESZEL_APP_URL` are now optional overrides. By default the render step derives them from `DOMAIN`.

## Deploy

Render runtime files and start the stack from this checkout:

```sh
mise run stack:render
mise run stack:config
mise run stack:deploy
```

The deploy script renders `runtime/` and `infra/docker/.env`, then runs:

```sh
docker compose -f docker-compose.yml up -d --remove-orphans
```

## Beszel Agent

The Beszel agent is behind the `agent` Compose profile and is configured to monitor the Docker host itself over a local Unix socket.
Enable it only when `BESZEL_AGENT_KEY` is set in Doppler:

```sh
export COMPOSE_PROFILES=agent
mise run stack:deploy
```

In the Beszel Hub, add the host system with `/beszel_socket/beszel.sock` as the Host / IP.
`BESZEL_AGENT_KEY` is the Hub public key shown when adding the system.

## Rollback

From the Docker host directory:

```sh
docker compose -f docker-compose.yml down
```

Persistent state is in Docker named volumes prefixed with `homelab_`. Do not remove those volumes unless you intentionally want to erase service data.
