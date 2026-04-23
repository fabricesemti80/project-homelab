# Docker Stack

The host-level Docker layer lives under `infra/docker/` and is managed separately from the Kubernetes cluster.

## Purpose

This stack provides the supporting services that either sit outside Kubernetes or help bootstrap and operate the rest of the homelab.

Common examples include:

1. Traefik
2. Cloudflared
3. Beszel
4. WhoAmI
5. Uptime Kuma
6. Arcane

Omni and its Proxmox provider are intentionally not part of this Docker tier.

## Deployment Model

The Docker stack is rendered and deployed from the Docker host checkout using `mise` tasks:

```bash
mise run stack:render
mise run stack:config
mise run stack:deploy
```

## Secrets and Runtime Files

-   Doppler is the source of Docker deployment secrets for this repo
-   active Docker secret scope: `project-homelab / dev_homelab`
-   `DOMAIN` is the primary hostname input; service hostnames and app URLs are derived from it unless explicitly overridden
-   rendered runtime files are written to `infra/docker/runtime/`
-   local secret material belongs under `infra/docker/secrets/`
-   these runtime and secret paths stay out of Git

## Related Documents

-   [Architecture Plan](../architecture/ARCHITECTURE_PLAN.md)
-   [OpenTofu Setup](terraform.md)
