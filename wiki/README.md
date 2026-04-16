# Homelab Documentation Wiki

Welcome to the documentation wiki for the Personal Homelab project. This wiki documents the architecture, configuration, and workflows used to manage the Talos Kubernetes cluster and supporting host-level Docker infrastructure.

## Table of Contents

### 1. General Architecture & Docker Platform

The base tier of this homelab is driven by a Proxmox host (`10.0.40.61`) running Docker, which handles essential routing, proxying, and the control planes for cluster node orchestration.

- [Docker Infrastructure Overview](docker-services.md) - Details on Traefik, Beszel, Dex, Cloudflared, and Arcane setups.

### 2. Sidero Omni

Sidero Omni is deployed as a self-hosted SaaS UI to orchestrate Talos VMs.

- [Self-Hosted Omni Quickstart](omni-overview.md) - Setup, authentication (Dex), and configuration of the main console.

### 3. Talos & Proxmox Integration

Proxmox acts as the infrastructure provider. Through the Siderolabs Omni Proxmox plugin, virtual machines are programmatically constructed, bootstrapped with Talos, and linked to Omni seamlessly without ISO juggling.

- [Talos on Proxmox Provisioning Guide](talos-proxmox-provisioning.md) - How to provision clusters, manage the Proxmox Infrastructure Provider, and understand `omnictl` operations.
