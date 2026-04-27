# Homelab Architecture Plan

## Objective

Operate the homelab from a single primary repository while keeping changes small, reversible, and explicit about security and rollback.

## Active Structure

-   `infra/docker/`: host-level Docker services that support the homelab outside Kubernetes.
-   `infra/terraform/`: current repo-native infrastructure for the Docker layer and related shared services.
-   `terraform/`, `talos/`, `kubernetes/`, `bootstrap/`, and `.taskfiles/`: root-level Talos, Argo CD, and OpenTofu workspace migrated from the legacy cluster repo.
-   `kubernetes/apps/default/`: lightweight default-namespace apps used for baseline GitOps validation and small utility workloads.

## Current Migration Direction

-   `project-homelab` becomes the main source of truth.
-   The old `home-argo-cluster-2025` repo stays intact during transition.
-   Argo CD will be repointed to `project-homelab`.
-   The active Talos cluster is now modeled as three control-plane nodes only.
-   Historical worker VMs remain infrastructure artifacts for rollback or later reuse, but are no longer part of the committed Talos node inventory.

## Assumptions

-   The imported cluster should keep using its current Proxmox IDs, node IPs, Talos secrets, and Terraform state.
-   Secrets and runtime artifacts remain local-only and gitignored.
-   Doppler project names and existing external integrations can stay unchanged during the repo migration.
-   Removing workers from Talos configuration does not require deleting the underlying VM definitions on the same change.

## Validation Checks

-   `task tf:init`
-   `task tf:plan`
-   `kubectl get nodes`
-   `talosctl --talosconfig talos/clusterconfig/talosconfig config info`
-   `task sync-argo-bootstrap`

## Rollback

-   Repoint Argo CD back to `home-argo-cluster-2025`.
-   Continue operating from the original repo because its state and files remain untouched.
-   Restore any copied local-only runtime files from the old workspace if the new one is discarded.
-   Reintroduce worker nodes by restoring them to `nodes.yaml`, regenerating `talos/talconfig.yaml`, and re-running Talos config generation.
