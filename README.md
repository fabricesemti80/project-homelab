# project-homelab

> **Automated, Declarative, and Hybrid Infrastructure-as-Code.**

This repository is the central source of truth for a personal homelab overhaul. It manages a staged transition from host-level Docker services to a fully orchestrated 3-node **Talos Linux** Kubernetes cluster on **Proxmox**.

## 🏗️ Architecture Roadmap

The project is structured into four distinct phases:

1.  **🚀 Phase 1: Mini-Docker Layer**
    A transportable Docker stack providing core management and remote access (Omni, Traefik, Cloudflared, Beszel, Arcane).
2.  **🌌 Phase 2: Talos Cluster**
    Provisioning a highly available 3-node Kubernetes cluster on Proxmox using immutable Talos Linux.
3.  **📡 Phase 3: Networking & Storage**
    Implementing Cilium CNI, Longhorn block storage, and NAS-based NFS for persistent media.
4.  **🔄 Phase 4: GitOps & Applications**
    Full lifecycle management via ArgoCD, migrating workloads from legacy clusters.

## 🚦 Start Here

- **Architecture Plan**: [ARCHITECTURE_PLAN.md](docs/architecture/ARCHITECTURE_PLAN.md)
- **Phase 0/1 Blueprint**: [PHASE_0_1_BLUEPRINT.md](docs/architecture/PHASE_0_1_BLUEPRINT.md)
- **Agent Guidance**: [AGENTS.md](AGENTS.md)

## 🛠️ Management Principles

- **Mise-First**: All operations (provisioning, linting, deployment) are handled via `mise` tasks.
- **Security**: Secret management initially uses `.envrc` (local-only), with a planned migration to **Doppler**.
- **Immutability**: Focus on declarative configuration and OS-less (Talos) node management.

## 🕹️ Core Tasks

Ensure you have `mise` installed on your system.

```bash
# Install toolchain and dependencies
mise install

# Deploy host-level Docker stack
mise run docker:deploy

# Plan Terraform changes
mise run tf:plan
```
