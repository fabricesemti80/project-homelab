# Docker Deployment

This directory owns the Docker deployment for services that used to be declared as NixOS `oci-containers` on `trinity`.
It is intentionally plain Docker Compose so it can run on non-Nix machines.

## Layout

- `docker-compose.yml`: main Compose entrypoint. It includes each service-specific Compose file.
- `arcane/`, `beszel/`, `cloudflared/`, `traefik/`, `uptime-kuma/`, `whoami/`: one directory per service group.
- `scripts/render-secrets.sh`: renders ignored runtime files from the repository root `.envrc`.
- `scripts/deploy.sh`: renders runtime files and deploys either locally or to a remote Docker server.
- `runtime/`: generated config and secret mounts consumed by Compose. Ignored by Git.
- `secrets/`: local source secret material. Ignored by Git.

## Required Local Secrets

The root `.envrc` is local and ignored. It must provide:

- `CLOUDFLARED_TUNNEL_TOKEN`
- `TRAEFIK_CLOUDFLARE_API_TOKEN`, `TRAEFIK_CLOUDFLARE_ZONE_ID`, `TRAEFIK_CLOUDFLARE_EMAIL`
- `ARCANE_ENCRYPTION_KEY`, `ARCANE_JWT_SECRET`

## Deploy

Local Docker host:

```sh
mise run docker:deploy
```

Remote Docker host:

```sh
export HOMELAB_DOCKER_HOST=fs@10.0.40.19
export HOMELAB_DOCKER_REMOTE_DIR=/opt/project-homelab/infra/docker
mise run docker:deploy
```

The deploy script renders `runtime/` and `infra/docker/.env`, copies this Docker bundle to the remote host over SSH without copying local source `secrets/`, then runs:

```sh
docker compose -f docker-compose.yml up -d --remove-orphans
```

## Beszel Agent

The Beszel agent is behind the `agent` Compose profile. Enable it only when `BESZEL_AGENT_KEY` and `BESZEL_AGENT_TOKEN` are set:

```sh
export COMPOSE_PROFILES=agent
mise run docker:deploy
```

## Rollback

From the Docker host directory:

```sh
docker compose -f docker-compose.yml down
```

Persistent state is in Docker named volumes prefixed with `homelab_`. Do not remove those volumes unless you intentionally want to erase service data.
