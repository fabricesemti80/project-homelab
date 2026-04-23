# OpenTofu Setup

This repository currently has two OpenTofu stacks.

## Stack Layout

-   `infra/terraform/`: host-level shared infrastructure that supports the Docker layer and related services
-   `terraform/`: the imported Talos cluster infrastructure stack

## Inputs and Local State

-   `terraform/*.auto.tfvars` holds local cluster-specific inputs and remains gitignored
-   `nodes.yaml` is still updated from Terraform outputs for the Talos workflow
-   local state is currently kept in the repo working copy for the imported cluster stack and should be treated as operator-local

## Common Commands

```bash
mise run tf:init
mise run tf:plan
mise run tf:apply
```

Cluster-only aliases:

```bash
mise run cluster:tf:init
mise run cluster:tf:plan
mise run cluster:tf:apply
```

## Related Documents

-   [Architecture Plan](../architecture/ARCHITECTURE_PLAN.md)
-   [Argo Cluster Migration](../architecture/ARGO_CLUSTER_MIGRATION.md)
-   [Cluster Docs Overview](../cluster/README.md)
