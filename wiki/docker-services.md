# Docker Services Platform

Before the Talos Kubernetes cluster can be fully managed, a host-level foundation is generated natively on Docker. This ensures foundational routing, VPN mesh networking, and basic ingress controls exist cleanly.

## The Docker Stack

Stored under `infra/docker/`, this tier is completely containerized inside a `docker-compose.yml` payload, which is pushed securely via SSH deployment scripts on demand (`mise run docker:deploy`).

### Core Services

1. **Traefik (Ingress Provider)**
   Handles ACME Let's Encrypt validation via Cloudflare DNS challenges and securely reverse proxies HTTPS traffic to adjacent Docker network containers.

2. **Cloudflared (Argo Tunnels)**
   Creates zero-trust inbound tunnels allowing the lab to remain cloaked and NAT'd, broadcasting explicit routes out to Cloudflare edge networks securely.

3. **Beszel**
   A lightweight observability platform providing basic resource telemetrics on the root Proxmox nodes directly, bypassing Kubernetes overhead.

4. **WhoAmI**
   A testing endpoint for confirming Traefik HTTP headers, network mappings, and general resolution validation during bring-up.

5. **Uptime Kuma**
   Service-level uptime monitoring for public and internal endpoints, complementing Beszel's infrastructure metrics.

6. **Arcane**
   Internal secrets and artifact management utility.

Omni and its Proxmox provider are intentionally not part of this Docker tier.

## Operations & Environment Mapping

Secrets never live in GitHub. The entire Docker hierarchy relies heavily on `direnv` pulling variables from an `.envrc` context natively.

When invoking `mise run docker:deploy`:

1. `render-secrets.sh` parses `.envrc` directly.
2. It generates scoped file mappings and the Compose `.env` directly to an un-tracked `runtime/` folder.
3. It securely performs an `rsync` push to the Proxmox target node over SSH.
4. It triggers a `docker compose up -d` against the synchronized configurations to execute idempotently.
