# AGENTS.md

## Purpose
This repository captures the design and implementation plan for a personal homelab.
All automation, IaC, and documentation should optimize for **repeatability**, **security**, and **clear rollback paths**.
This repository is also the main deployment home for the Talos cluster and the host-level Docker services that support it.

## Working rules for agents
1. **Plan before build**: update architecture/design docs before introducing new infrastructure code.
2. **Never commit secrets**: API keys, tokens, private keys, kubeconfigs, `.envrc`, generated Docker runtime files, and `.env` files must stay out of Git.
3. **Small, reversible changes**: keep PRs scoped; include migration/rollback notes for impactful changes.
4. **Document assumptions**: every design decision should list assumptions and validation checks.
5. **Use explicit environments**: `dev`, `stage`, and `prod` (or `lab`) should be modeled separately.

## Repository conventions
- High-level architecture documents live under `docs/architecture/`.
- Implementation task breakdowns live under `docs/plan/`.
- Scripts should be idempotent where practical.
- Prefer Markdown checklists for progress tracking.
- Host-level Docker services live under `infra/docker/`, not in NixOS modules.
- Each Docker service should have its own subdirectory and be included from `infra/docker/docker-compose.yml`.
- Rendered Docker runtime config belongs in `infra/docker/runtime/` and must remain ignored.
- Local source secret material belongs in `infra/docker/secrets/` and must remain ignored.
- The root `.envrc` is the local source for Docker deployment secrets and deployment target variables.

## Docker Deployment Rules
- Use `mise run docker:render` before validating Compose config.
- Use `mise run docker:deploy` for local or remote Docker deployment.
- Remote deployment is controlled by `HOMELAB_DOCKER_HOST` and `HOMELAB_DOCKER_REMOTE_DIR` from `.envrc`.
- Prefer remote SSH deployment over assuming the host is NixOS-specific.
- Omni secrets are rendered from `.envrc` into `infra/docker/runtime/secrets/omni`; do not hand-edit generated runtime files.
- Use `mise run docker:omni:envrc` only when intentionally rotating Omni CA/certs/GPG/Dex credentials.
- Omni currently uses host networking for SideroLink/WireGuard; do not move it to Docker bridge networking without validating Talos node connectivity.

## Definition of done (for infra tasks)
- Architecture or design doc updated.
- Security impact considered (network, secrets, access control, backups).
- Validation steps included (lint/plan/test/deploy checks).
- Rollback approach documented.
