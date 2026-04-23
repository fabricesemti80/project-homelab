# Phase 0/1 Implementation Blueprint

## Objective

Deliver a bootstrapped Talos Kubernetes cluster on Proxmox with private-only Tailscale access and GitOps baseline ready for Phase 2.

## 1) Current VM matrix

| Node        | Role          |  Target IP | VMID | vCPU |   RAM | OS Disk | Data Disk |
| ----------- | ------------- | ---------: | ---: | ---: | ----: | ------: | --------: |
| k8s-ctrl-01 | control-plane | 10.0.40.90 | 4090 |    4 | 8 GiB |  30 GiB |       n/a |
| k8s-ctrl-02 | control-plane | 10.0.40.91 | 4091 |    4 | 8 GiB |  30 GiB |       n/a |
| k8s-ctrl-03 | control-plane | 10.0.40.92 | 4092 |    4 | 8 GiB |  30 GiB |       n/a |

The current steady state favors control planes only. Historical worker VMs may remain defined in OpenTofu for rollback, but they are no longer part of the active Talos node inventory.

## 2) Placement strategy

-   Place each control-plane VM on a different Proxmox node.
-   Enable restart-on-boot and HA policy where available.

## 3) Bootstrap order

1. Apply the cluster OpenTofu stack and power on the control planes.
2. Generate Talos machine configs.
3. Bootstrap first control-plane.
4. Join remaining control-plane nodes.
5. Reconcile cluster apps from Argo CD.
6. Install Cilium.
7. Validate Envoy Gateway external ingress.
8. Install Argo CD.
9. Validate Ceph CSI and storage workloads.
10. Validate observability baseline.

## 4) Repository layout proposal

```text
infra/terraform/        # Docker-side and shared host-level infrastructure
terraform/              # Talos cluster and tunnel infrastructure
talos/                  # Talos cluster configuration
kubernetes/             # Argo apps and cluster manifests
bootstrap/              # Helmfile-based cluster bootstrap
```

## 5) Mise task skeleton (planned)

-   `mise run validate`
-   `mise run infra:provision`
-   `mise run talos:genconfig`
-   `mise run talos:bootstrap`
-   `mise run apps:bootstrap`
-   `mise run platform:cilium`
-   `mise run platform:ingress`
-   `mise run platform:argocd`
-   `mise run platform:observability`
-   `mise run verify:cluster`

## 6) Exit criteria for Phase 1

-   Kubernetes API reachable privately.
-   Control plane healthy and routable.
-   Cilium and Envoy Gateway healthy.
-   Argo CD operational and syncing from Git.
-   Worker VMs can be reintroduced later by restoring them to the Talos node inventory and regenerating config.
