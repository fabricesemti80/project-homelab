# Self-Hosted Omni Overview

Sidero Omni is a Kubernetes cluster lifecycle manager, usually provided as a SaaS application by Sidero Labs. In this homelab, it is totally self-hosted via Docker and deeply integrated with our identity tools.

## Key Components

1. **The Omni Server Container (`omni`)**
   Omni runs via Docker passing a custom SQLite database and ETCD structure under `infra/docker/_out`.

   - **Internal Binding:** Listens on port `8443` for standard HTTP/gRPC requests, proxy-routed by Traefik on the `homelab_proxy` network.
   - **SideroLink Tunneling:** Listens directly on host port `50180/udp` (or via Docker port bind) for WireGuard SideroLink tunnels connecting directly to Talos workloads.

2. **Authentication via Dex**
   Omni offloads authentication to a bundled Dex instance which acts as an OIDC provider. Dex itself uses static credentials established via our `.envrc` renderer.

3. **Traefik Routing**
   Traefik proxies public HTTPS traffic to the internal `8443` port of Omni. Proper SSL is negotiated by Cloudflare DNS and Let's Encrypt, with Omni implicitly trusting these certs because we mount our Root CA (`full-chain.pem`) directly into Omni's trust store.

## Infrastructure Initialization

### Account Configuration

Unlike SaaS versions of Omni, our localized Omni requires a stable `ACCOUNT_ID`. We explicitly inject a fixed UUID into the `omni` runtime arguments via `--account-id=${OMNI_ACCOUNT_ID}`. This guarantees that Omni doesn't reset its tenant logic or abandon endpoints on container rebuilds.

### TLS Certificates & GPG

Certificates for Omni's Web UI, Machine APIs, and Dex authentication are generated on-the-fly and rendered securely by `infra/docker/scripts/render-secrets.sh`. The required source keys sit securely out of version control and are piped via `.envrc`.

## Troubleshooting

- **EULA Lockout?**
  If Omni or connected client endpoints display a "EULA not accepted" error (typically following a hard reset), explicitly access the `https://omni...` URL via a browser and complete the prompt natively.
- **Provider Connection Refused**
  Provider plugins must interact with the _main API port_ (`8443`), not the specialized machine endpoint (`8095`). If changing the API listener in `omni/compose.yml`, reflect it immediately in `omni-proxmox/compose.yml` or downstream components will experience DNS failures.
