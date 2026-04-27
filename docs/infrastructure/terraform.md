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
task tf:init
task tf:plan
task tf:apply
```

Cluster-only aliases:

```bash
task cluster:tf:init
task cluster:tf:plan
task cluster:tf:apply
```

## Related Documents

-   [Architecture Plan](../architecture/ARCHITECTURE_PLAN.md)
-   [Argo Cluster Migration](../architecture/ARGO_CLUSTER_MIGRATION.md)
-   [Cluster Docs Overview](../cluster/README.md)
