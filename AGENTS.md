# AGENTS.md

## Purpose
This repository captures the design and implementation plan for a personal homelab.
All automation, IaC, and documentation should optimize for **repeatability**, **security**, and **clear rollback paths**.

## Working rules for agents
1. **Plan before build**: update architecture/design docs before introducing new infrastructure code.
2. **Never commit secrets**: API keys, tokens, private keys, kubeconfigs, and `.env` files must stay out of Git.
3. **Small, reversible changes**: keep PRs scoped; include migration/rollback notes for impactful changes.
4. **Document assumptions**: every design decision should list assumptions and validation checks.
5. **Use explicit environments**: `dev`, `stage`, and `prod` (or `lab`) should be modeled separately.

## Repository conventions
- High-level architecture documents live under `docs/architecture/`.
- Implementation task breakdowns live under `docs/plan/`.
- Scripts should be idempotent where practical.
- Prefer Markdown checklists for progress tracking.

## Definition of done (for infra tasks)
- Architecture or design doc updated.
- Security impact considered (network, secrets, access control, backups).
- Validation steps included (lint/plan/test/deploy checks).
- Rollback approach documented.
