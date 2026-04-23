# Argo Cluster Relocation

## Goal

Relocate the existing Talos/Argo cluster workflow from `home-argo-cluster-2025` into `project-homelab` without destroying the old repo, without recreating the VMs, and without forcing the worker nodes back online.

## What Was Imported

-   Tracked cluster workspace files were merged into the `project-homelab` repo root.
-   Local-only runtime files were copied into the new workspace and remain gitignored.
-   The current OpenTofu state was copied into `terraform/terraform.tfstate`.
-   Argo bootstrap manifests now point to `https://github.com/fabricesemti80/project-homelab.git`.
-   Argo application paths now target the root-level `kubernetes/...` paths in this repo.
-   The encrypted Argo repository secret was re-encrypted with the new repo URL.

## Important Constraint

The imported Terraform module originally forced every Talos VM to `started = true`. That would have powered the workers back on during the first apply from the new repo. The imported workspace now supports a per-node `started` flag so worker VMs can remain provisioned but powered off.

## Recommended Cutover Sequence

1. Push `project-homelab` with the imported cluster workspace to GitHub.
2. In `terraform/nodes.auto.tfvars`, keep worker nodes `started = false` and control-plane nodes `true`.
3. Run `task tofu:init`.
4. Run `task tofu:plan` and confirm the plan is limited to the repo/path-related changes you expect.
5. Power on only the control-plane VMs if they are currently off.
6. Verify Talos and Kubernetes health from the imported workspace.
7. Apply the Argo bootstrap resources from the imported workspace so the cluster pulls from `project-homelab`.
8. Leave the workers powered off until you explicitly want them back in service.

## Validation

-   `task tofu:plan`
-   `kubectl get nodes -o wide`
-   `talosctl --talosconfig talos/clusterconfig/talosconfig health`
-   `task sync-argo-bootstrap`

## Security Notes

-   No secrets were added to Git; copied runtime files stay ignored by the root `.gitignore`.
-   The imported workspace still uses the existing age recipient and Doppler project references.
-   If the GitHub deploy key is scoped to the old repository only, add the same public key to `project-homelab` before switching Argo over.

## Rollback

-   Keep using `home-argo-cluster-2025` as the operator workspace.
-   Reapply the old bootstrap manifests to point Argo back at the old repository.
-   Remove the imported workspace later once the new repo has proven stable.
