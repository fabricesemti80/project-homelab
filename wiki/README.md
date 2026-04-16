# Homelab Documentation Wiki

Welcome to the documentation wiki for the Personal Homelab project. This wiki documents the architecture, configuration, and workflows used to manage the Talos Kubernetes cluster and supporting host-level Docker infrastructure.

## Table of Contents

### 1. General Architecture & Docker Platform

The base tier of this homelab is driven by a Proxmox host (`10.0.40.61`) running Docker, which handles essential routing, proxying, remote access, and lightweight support services.

- [Docker Infrastructure Overview](docker-services.md) - Details on Traefik, Beszel, Cloudflared, Arcane, and validation endpoints.

### 2. Talos & Proxmox Integration

Proxmox remains the infrastructure provider. Talos VM provisioning should use Terraform and Talos-native bootstrap workflows instead of Omni.
