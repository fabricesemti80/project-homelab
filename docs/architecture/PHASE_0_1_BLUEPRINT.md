# Phase 0/1 Implementation Blueprint (Draft)

## Objective
Deliver a bootstrapped Talos Kubernetes cluster on Proxmox with private-only Tailscale access and GitOps baseline ready for Phase 2.

## 1) Planned VM matrix (initial)

| Node | Role | Target IP | VMID | vCPU | RAM | OS Disk | Data Disk |
|---|---|---:|---:|---:|---:|---:|---:|
| talos-cp-1 | control-plane | 10.0.30.61 | 4061 | 4 | 6 GiB | 40 GiB | n/a |
| talos-cp-2 | control-plane | 10.0.30.62 | 4062 | 4 | 6 GiB | 40 GiB | n/a |
| talos-cp-3 | control-plane | 10.0.30.63 | 4063 | 4 | 6 GiB | 40 GiB | n/a |
| talos-wk-1 | worker | 10.0.30.71 | 4071 | 4 | 8 GiB | 40 GiB | 100 GiB (Longhorn) |
| talos-wk-2 | worker | 10.0.30.72 | 4072 | 4 | 8 GiB | 40 GiB | 100 GiB (Longhorn) |
| talos-wk-3 | worker | 10.0.30.73 | 4073 | 4 | 8 GiB | 40 GiB | 100 GiB (Longhorn) |

> Sizing is a safe starting point and should be tuned after actual workload profiling.

## 2) Placement strategy
- Place each control-plane VM on a different Proxmox node.
- Place each worker VM on a different Proxmox node.
- Enable restart-on-boot and HA policy where available.

## 3) Bootstrap order
1. Provision all 6 Talos VMs (static IP + VMID convention).
2. Generate Talos machine configs.
3. Bootstrap first control-plane.
4. Join remaining control-plane nodes.
5. Join worker nodes.
6. Install Cilium.
7. Install ingress controller.
8. Install Argo CD.
9. Install Longhorn.
10. Install observability baseline.

## 4) Repository layout proposal

```text
infra/
  proxmox/
  talos/
platform/
  cilium/
  ingress/
  argocd/
  longhorn/
  observability/
apps/
  bootstrap/
  services/
ops/
  backups/
  runbooks/
```

## 5) Mise task skeleton (planned)
- `mise run validate`
- `mise run infra:provision`
- `mise run talos:genconfig`
- `mise run talos:bootstrap`
- `mise run platform:cilium`
- `mise run platform:ingress`
- `mise run platform:argocd`
- `mise run platform:longhorn`
- `mise run platform:observability`
- `mise run verify:cluster`

## 6) Exit criteria for Phase 1
- Kubernetes API reachable privately via Tailnet paths.
- All 6 nodes stable and Ready.
- Cilium and ingress healthy.
- Argo CD operational and syncing from Git.
- Runbook exists for control-plane replacement and worker replacement.
