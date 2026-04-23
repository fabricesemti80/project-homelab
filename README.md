# project-homelab

> **Automated, Declarative, and Hybrid Infrastructure-as-Code.**

This repository is the central source of truth for a personal homelab overhaul. It manages host-level Docker services and the Talos/Argo cluster in the same root-level repo.

## 🏗️ Architecture Roadmap

The project is structured into four distinct phases:

1.  **🚀 Phase 1: Mini-Docker Layer**
    A transportable Docker stack providing core routing, remote access, monitoring, and admin utilities (Traefik, Cloudflared, Beszel, Arcane).
2.  **🌌 Phase 2: Talos Cluster**
    Operating the Talos/Argo cluster from this same repo root, with Terraform state and GitOps definitions now co-located here.
3.  **📡 Phase 3: Networking & Storage**
    Operating the migrated cluster’s Cilium, Envoy Gateway, and Ceph CSI stack here.
4.  **🔄 Phase 4: GitOps & Applications**
    Full lifecycle management via ArgoCD, migrating workloads from legacy clusters.

## 🚦 Start Here

-   **Architecture Plan**: [ARCHITECTURE_PLAN.md](docs/architecture/ARCHITECTURE_PLAN.md)
-   **Argo Cluster Migration**: [ARGO_CLUSTER_MIGRATION.md](docs/architecture/ARGO_CLUSTER_MIGRATION.md)
-   **Phase 0/1 Blueprint**: [PHASE_0_1_BLUEPRINT.md](docs/architecture/PHASE_0_1_BLUEPRINT.md)
-   **Agent Guidance**: [AGENTS.md](AGENTS.md)

## 🛠️ Management Principles

-   **Mise-First**: All operations (provisioning, linting, deployment) are handled via `mise` tasks.
-   **Security**: Secret management initially uses `.envrc` (local-only), with a planned migration to **Doppler**.
-   **Immutability**: Focus on declarative configuration and OS-less (Talos) node management.

## 🕹️ Core Tasks

Ensure you have `mise` installed on your system.

```bash
# Install toolchain and dependencies
mise install

# Install Helm plugins used by the cluster workflow
mise run deps

# Deploy host-level Docker stack
mise run stack:deploy

# Plan both OpenTofu stacks
mise run tf:plan
```

For cluster bootstrap and verification:

```bash
mise run tf:init
mise run talos:genconfig
mise run talos:bootstrap
mise run apps:bootstrap
mise run verify:cluster
```

`mise run tf:plan` and `mise run tf:apply` cover both:

```bash
infra/terraform
terraform
```
