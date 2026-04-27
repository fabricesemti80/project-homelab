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

Execution order:

-   `task tf:init` initializes the node stack in `terraform/` first, then the shared infra stack in `infra/terraform/`
-   `task tf:plan` plans nodes first, then shared infra
-   `task tf:apply` applies nodes first, then shared infra

## Related Documents

-   [Architecture Plan](../architecture/ARCHITECTURE_PLAN.md)
-   [Argo Cluster Migration](../architecture/ARGO_CLUSTER_MIGRATION.md)
-   [Cluster Docs Overview](../cluster/README.md)
