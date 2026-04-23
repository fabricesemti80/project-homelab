# Homelab Architecture Plan

## Objective

Operate the homelab from a single primary repository while keeping changes small, reversible, and explicit about security and rollback.

## Active Structure

-   `infra/docker/`: host-level Docker services that support the homelab outside Kubernetes.
-   `infra/terraform/`: current repo-native infrastructure for the Docker layer and related shared services.
-   `terraform/`, `talos/`, `kubernetes/`, `bootstrap/`, and `.taskfiles/`: root-level Talos, Argo CD, and OpenTofu workspace migrated from the legacy cluster repo.

## Current Migration Direction

-   `project-homelab` becomes the main source of truth.
-   The old `home-argo-cluster-2025` repo stays intact during transition.
-   Argo CD will be repointed to `project-homelab`.
-   Existing worker VMs remain defined, but may stay powered off until we explicitly reintroduce them.

## Assumptions

-   The imported cluster should keep using its current Proxmox IDs, node IPs, Talos secrets, and Terraform state.
-   Secrets and runtime artifacts remain local-only and gitignored.
-   Doppler project names and existing external integrations can stay unchanged during the repo migration.

## Validation Checks

-   `task tofu:init`
-   `task tofu:plan`
-   `kubectl get nodes`
-   `task sync-argo-bootstrap`

## Rollback

-   Repoint Argo CD back to `home-argo-cluster-2025`.
-   Continue operating from the original repo because its state and files remain untouched.
-   Restore any copied local-only runtime files from the old workspace if the new one is discarded.
