# Implementation Decisions

## Confirmed

- Network: VLAN30 (`10.0.30.0/24`).
- Access model: Tailscale for both node-level and subnet routing scenarios.
- CNI: Cilium (target configuration enables kube-proxy replacement).
- Ingress: Traefik.
- Storage: Longhorn with dedicated worker data disks (initial target 100 GiB per worker).
- GitOps: Argo CD.
- Media service: remains on NAS Docker initially, routed via cluster ingress as external upstream.

## Pending final user confirmation

- Initial 5 application services to onboard after platform baseline.
- RPO/RTO tier definitions for critical services.
