<<<<<<< ours
<<<<<<< ours
<<<<<<< ours
<<<<<<< ours

# Homelab Architecture Plan (Working Draft)

## 1) Objective

Design a secure, maintainable homelab architecture that can be implemented in staged milestones.

---

## 2) Planning workflow we will follow

1. **Requirement capture** (what you want to run and why).
2. **Constraint mapping** (budget, hardware, power, ISP limitations, risk tolerance).
3. **Target architecture draft** (network, compute, storage, identity, observability, backups).
4. **Trade-off review** (simplicity vs. flexibility, cost vs. resilience).
5. **Phased implementation plan** with validation and rollback.
6. **Execution tracking** via milestone checklists.

---

## 3) Requirement intake template

Fill this in (or answer conversationally) and we will refine the architecture.

| Area        | Questions to answer                                                                |
| ----------- | ---------------------------------------------------------------------------------- |
| Goals       | What outcomes matter most (learning, self-hosting, media, HA, AI workloads, etc.)? |
| Services    | Which apps/services do you want first? Which are optional later?                   |
| Hardware    | Existing devices (CPU/RAM/storage/NIC), future purchases, and budget ceiling?      |
| Network     | Current router/firewall, VLAN needs, remote access needs, DNS/domain ownership?    |
| Security    | Threat model, MFA, SSO, secret management expectations?                            |
| Data        | Critical data sets, retention requirements, expected growth?                       |
| Backups/DR  | Recovery-time objective (RTO) and recovery-point objective (RPO)?                  |
| Operations  | Comfort with Kubernetes, Docker, Terraform, Ansible, GitOps?                       |
| Reliability | Desired uptime targets and tolerance for maintenance windows?                      |

---

## 4) Architecture design domains (what we will design)

- **Edge & networking**: router/firewall, VLAN segmentation, inter-VLAN policy, ingress strategy.
- **Compute platform**: hypervisor/container orchestration strategy.
- **Storage**: primary storage, snapshots, backup targets, offsite strategy.
- **Identity & access**: users/groups, SSO, service credentials, rotation policy.
- **Observability**: metrics, logs, alerts, dashboards.
- **Platform security**: patching baseline, hardening, secrets handling.
- **Automation & IaC**: declarative config and promotion workflow.

---

## 5) Milestones to completion

### Milestone 0 — Discovery & baseline

- [ ] Finalize requirements table.
- [ ] Build asset inventory (hardware + network map).
- [ ] Identify current risks and quick wins.

### Milestone 1 — Foundation architecture

- [ ] Finalize reference architecture diagram (logical).
- [ ] Define network segmentation and firewall policy baseline.
- [ ] Define naming conventions and environment structure.

### Milestone 2 — Core platform

- [ ] Deploy base compute layer.
- [ ] Provision core storage and snapshot policy.
- [ ] Establish IAM and secrets workflow.

### Milestone 3 — Operations baseline

- [ ] Add observability stack (metrics/logging/alerts).
- [ ] Add backup + restore testing routine.
- [ ] Add patching and lifecycle automation.

### Milestone 4 — Service rollout

- [ ] Deploy priority services in order.
- [ ] Validate security controls and SLOs.
- [ ] Document runbooks and rollback steps.

### Milestone 5 — Hardening & optimization

- [ ] Threat-model review.
- [ ] Performance/cost optimization pass.
- [ ] Quarterly architecture review cadence.

---

## 6) Definition of complete architecture design

The design phase is complete when:

- All requirements have explicit decisions or deferred rationale.
- A target-state architecture exists across all design domains.
- A phased implementation plan has estimates, dependencies, validation, and rollback notes.
- Open questions are explicitly listed and prioritized.

---

## 7) Open questions (to fill as we work)

- [ ]
- [ ]
- [ ]

---

## 8) Next actions

- [ ] You provide goals/services/constraints using Section 3.
- [ ] I produce a first-pass target architecture.
- [ ] # We iterate and freeze Milestone 1 design.

# Homelab Kubernetes Architecture Plan

## 1) Inputs confirmed

- Proxmox cluster with **3 nodes** is already available.
- NAS is available and exports **NFS shares**.
- You already have **Tailscale** and **Cloudflare** accounts.
- Kubernetes should run on **Talos Linux** and be automated as much as possible.
- VM provisioning should use Terraform plus Talos-native bootstrap workflows; Omni is out of scope for the active deployment.
- GitOps control plane should be **Argo CD**.
- Initial access model is **private-only via Tailscale**; Cloudflare exposure can come later.
- NFS should be used for long-term media retention.
- You are considering **Longhorn** for Kubernetes persistent volumes.
- One media service stack (Plex/Jellyfin) may remain outside Kubernetes (likely Docker on NAS).

---

## 2) Design principles

1. **Automate everything possible** (bootstrap, cluster lifecycle, app rollout, upgrades).
2. **Plan for failure** (node loss, disk loss, network issues, control-plane outages).
3. **Preserve visibility** (dashboards, alerts, logs, and known-good runbooks).

---

## 3) Target architecture (v1)

### 3.1 Infrastructure layout

- **Proxmox layer**
  - 3 Proxmox nodes host Talos VMs.
  - Talos control-plane and worker VMs are distributed across all 3 nodes.
- **Kubernetes layer (Talos)**
  - 3 control-plane VMs (etcd quorum-safe).
  - 3+ worker VMs (initially 3 recommended, one per Proxmox node).
- **Storage layer**
  - **Longhorn** for RWX/RWO style cluster workloads requiring dynamic PVCs.
  - **NFS (NAS)** for media/archive/cold data and backup target(s).
- **Access layer**
  - Cluster and apps exposed internally through **Tailscale** only in phase 1.
  - Cloudflare Tunnel + DNS deferred to phase 2/3.
- **GitOps layer**
  - **Argo CD** manages cluster add-ons and workloads from Git.

### 3.2 Network and ingress model (phase 1)

- No public ingress in initial phase.
- Tailscale used for:
  - operator/admin access to Talos/Kubernetes endpoints,
  - private app access,
  - optional subnet routing/exit-node pattern if needed.
- Ingress controller (Traefik or NGINX) still deployed for consistent internal routing.

### 3.3 External media service routing

- Keep Plex/Jellyfin outside Kubernetes on NAS Docker (initially).
- Route traffic from cluster ingress to NAS service via static upstream/service entry.
- Treat NAS media service as an external dependency with health checks.

---

## 4) Automation stack proposal

## 4.1 Orchestration entrypoint

Use **Mise** as the unified task runner and toolchain manager.

Suggested task groups:

- `mise run validate` → lint, schema checks, policy checks.
- `mise run infra:provision` → Proxmox VM provisioning automation.
- `mise run talos:bootstrap` → Talos config generation + cluster bootstrap.
- `mise run platform:bootstrap` → CNI, CSI, ingress, Argo CD, observability.
- `mise run apps:sync` → Argo application bootstrap/sync.
- `mise run day2:upgrade` → Talos/K8s/add-on upgrades.
- `mise run drill:restore` → backup restore and failure drills.

## 4.2 IaC and config ownership

- Proxmox VM provisioning: Terraform-managed VM creation plus Talos-native bootstrap.
- Cluster OS + control-plane config: Talos machine configs in Git.
- Add-ons and apps: Argo CD app-of-apps or ApplicationSet pattern.
- Secrets: SOPS + age (or equivalent) before production workloads.

---

## 5) High-availability and failure planning

### 5.1 Control-plane resilience

- Minimum 3 Talos control-plane nodes.
- Enforce anti-affinity at Proxmox placement level (1 CP node per Proxmox host).
- Keep regular etcd snapshots and test recovery procedure.

### 5.2 Worker resilience

- Spread worker VMs across Proxmox nodes.
- Use PodDisruptionBudgets and anti-affinity for critical apps.

### 5.3 Storage resilience

- Longhorn replica count based on worker count and disk topology.
- Back up Longhorn volumes / app data to NAS or object target.
- Keep NFS only for cold/media retention and non-latency-sensitive data.

### 5.4 Operational visibility

- Metrics: Prometheus + Grafana.
- Logs: Loki + Promtail (or equivalent).
- Alerting: Alertmanager with Tailscale-reachable notification path.
- Uptime probes for control-plane, ingress, storage, and NAS media service.

---

## 6) Phased implementation plan

### Phase 0 — Discovery and constraints

- [ ] Hardware inventory (CPU, RAM, storage per Proxmox node).
- [ ] Validate NAS NFS performance/availability baseline.
- [ ] Define IP strategy and Tailscale architecture.
- [ ] Decide failure domains and acceptable downtime.

### Phase 1 — Cluster foundation

- [ ] Implement VM provisioning workflow on Proxmox (Talos-compatible).
- [ ] Bootstrap Talos control-plane + workers.
- [ ] Install CNI, CSI prerequisites, and ingress controller.
- [ ] Validate private-only access through Tailscale.

### Phase 2 — Platform services

- [ ] Deploy Argo CD and GitOps structure.
- [ ] Deploy Longhorn and storage classes.
- [ ] Deploy baseline observability stack.
- [ ] Add backup and restore workflow (and test it).

### Phase 3 — App onboarding

- [ ] Roll out core apps via Argo CD.
- [ ] Add ingress routes for internal apps over Tailnet.
- [ ] Add external service route to NAS media stack.

### Phase 4 — Hardening and day-2 ops

- [ ] Upgrade runbooks (Talos, Kubernetes, Longhorn, Argo).
- [ ] Failure drills (node down, disk failure, accidental deletion).
- [ ] Security hardening (RBAC, network policies, secret rotation).
- [ ] Optional Cloudflare Tunnel + DNS exposure pattern.

---

## 7) Deliverables checklist (design stage)

- [ ] Logical architecture diagram.
- [ ] Network and access model spec.
- [ ] Storage strategy doc (Longhorn + NFS roles).
- [ ] GitOps repository layout and promotion model.
- [ ] Day-2 operations runbook index.

---

## 8) Decisions to confirm

1. **Talos provisioning path**: Terraform-managed VMs plus Talos-native bootstrap; Omni is intentionally excluded.
2. **CNI preference**: Cilium vs. another CNI (Cilium recommended if no blocker).
3. **Ingress choice**: Traefik vs NGINX (you mentioned Traefik familiarity).
4. **Longhorn disks**: Dedicated virtual disks per worker available?
5. **Secrets management**: SOPS+age acceptable for GitOps secrets?
6. **Argo topology**: Single cluster Argo in-cluster vs. external management cluster later?
7. **Media routing**: Should Kubernetes ingress terminate TLS for NAS media service, or passthrough?
8. **Backup target**: NAS-only first, or dual target (NAS + cloud object) from start?

---

## 9) Questions I need answered next

Please answer these to lock Phase 0/1:

1. What are the specs of each Proxmox node (CPU threads, RAM, local disk type/size)?
2. Do you have a dedicated VLAN/subnet for cluster nodes, or should we introduce one?
3. How do you want Tailscale integrated: per-node agent, subnet router, or both?
4. Are you comfortable with Cilium + kube-proxy replacement, or prefer conservative defaults first?
5. Will Longhorn use dedicated virtual disks on each worker VM?
6. Which apps are in your **first 5** services to onboard via Argo CD?
7. For NAS-hosted media service, do you want SSO in front of it, or direct auth?
8. What RPO/RTO do you want for critical services?

---

## 10) Next actions

- [ ] You answer Section 9.
- [ ] I produce a concrete Phase 0/1 implementation blueprint (including repo structure and `mise` tasks).
- [ ] We finalize the bootstrap order and start execution.
  > > > > > > > theirs
  # =======
  > > > > > > > # theirs
  > > > > > > >
  > > > > > > > theirs

# Homelab Kubernetes Architecture Plan

## 1) Confirmed environment inputs

### Physical/virtualization baseline

- Proxmox cluster with **3 identical nodes**.
- Per-node specs (from provided screenshot):
  - CPU: **16 vCPU threads** (12th Gen Intel Core i7-12650H class)
  - RAM: **~31 GiB** usable
  - Local disk: **~432.8 GiB**
- NAS with NFS share is available.

### Network baseline

- Cluster VM network should use **VLAN30** (`10.0.30.0/24`).
- VM IDs follow your convention: `VMID = 4000 + last IP octet`.
- Existing occupancy exists in early range, so Kubernetes allocations should avoid first 50 IPs.

### Platform/tooling baseline

- Tailscale and Cloudflare accounts are ready.
- Desired cluster OS: **Talos Linux**.
- Preferred VM provisioning path: **Terraform-managed Proxmox VMs plus Talos-native bootstrap**.
- GitOps controller: **Argo CD**.
- Initial exposure model: **private-only over Tailscale**.
- Cloudflare tunnels/DNS are deferred to later phase.

### Service/storage baseline

- NFS on NAS is for long-term media retention.
- Longhorn is the candidate for dynamic Kubernetes PVs.
- Plex/Jellyfin likely stays off-cluster (Docker on NAS), with Kubernetes ingress routing to it.

---

## 2) Locked design choices (based on your answers)

1. **Tailscale integration mode**: use **both** node-level agents and subnet-router capability where useful.
2. **Primary CNI direction**: **Cilium** (recommended).
3. **Cluster address domain**: VLAN30 / `10.0.30.0/24`.

---

## 3) Recommended target topology (v1)

### 3.1 Talos/Kubernetes node topology

- Control plane: **3 Talos VMs** (1 per Proxmox node).
- Workers: **3 Talos VMs** to start (1 per Proxmox node), scale later if needed.
- Anti-affinity by placement policy: never co-locate all critical roles on a single Proxmox host.

### 3.2 Proposed IP + VMID reservation map

Suggested static reservation block (adjust if conflicts exist):

| Role              | IP range          | VMID rule         |
| ----------------- | ----------------- | ----------------- |
| Control plane     | `10.0.30.61-63`   | `4061-4063`       |
| Workers           | `10.0.30.71-73`   | `4071-4073`       |
| Future workers    | `10.0.30.74-89`   | `4074-4089`       |
| Ingress/LB VIP(s) | `10.0.30.90-99`   | reserved          |
| Platform services | `10.0.30.100-129` | `4100+` as needed |

> This avoids the early range while preserving your VMID=4000+IP convention.

### 3.3 Access and ingress model (phase 1)

- No internet-exposed ingress initially.
- Admin/API access over Tailscale.
- Internal app access over Tailscale.
- Ingress controller still deployed for stable service routing (Traefik recommended given your familiarity).

### 3.4 External NAS media service handling

- Keep Plex/Jellyfin on NAS Docker.
- Ingress route from cluster → NAS media endpoint as an external upstream.
- Health checks and explicit dependency notes in runbooks.

---

## 4) Longhorn disk design — explanation for your question #5

### Why dedicated virtual disks per worker are recommended

Longhorn stores replicated block data on each participating Kubernetes node. Using a dedicated disk per worker VM gives:

- predictable I/O isolation from OS/root disk,
- simpler capacity management,
- reduced blast radius when root filesystem has issues,
- cleaner backup/replacement lifecycle.

### Minimum practical pattern

- Add **one extra virtual disk** per worker VM, dedicated to Longhorn data.
- Start with 80–150 GiB per worker depending on expected PVC usage.
- Use same disk class/latency across workers when possible.

### If dedicated disks are not possible initially

- Longhorn can run on root disk paths, but this is a compromise:
  - higher risk of noisy-neighbor/storage pressure,
  - harder recovery and growth planning,
  - more operational risk during upgrades/failures.

Recommendation: dedicate disks from day 1 if capacity allows.

---

## 5) Automation and GitOps model

### 5.1 Task orchestration via Mise

Use `mise` as the primary operator entrypoint.

Proposed task namespaces:

- `mise run validate`
- `mise run infra:provision`
- `mise run talos:bootstrap`
- `mise run platform:bootstrap`
- `mise run apps:sync`
- `mise run day2:upgrade`
- `mise run drill:restore`

### 5.2 Source-of-truth boundaries

- Proxmox VM lifecycle: infra automation pipeline.
- Talos machine configs: Git.
- Kubernetes platform/apps: Argo CD-managed manifests/Helm.
- Secrets: SOPS+age (recommended) before production-like workloads.

---

## 6) High availability, failure, and observability

### 6.1 HA/failure design

- 3 control planes for etcd quorum.
- Worker spread across all Proxmox nodes.
- PodDisruptionBudgets + anti-affinity for critical services.
- Routine etcd snapshot and restore validation.

### 6.2 Storage resilience

- Longhorn replica count tuned to worker count and disk capacity.
- Backup important volumes to NAS target.
- Use NFS for cold/media retention rather than latency-sensitive DB workloads.

### 6.3 Visual observability baseline

- Metrics: Prometheus + Grafana.
- Logs: Loki + Promtail.
- Alerts: Alertmanager.
- Availability probes for API, ingress, Longhorn, and NAS media route.

---

## 7) Execution phases

### Phase 0 — Discovery finalization

- [ ] Confirm exact free IP slots on VLAN30.
- [ ] Confirm per-node free CPU/RAM headroom for 6 Talos VMs.
- [ ] Decide initial Longhorn per-worker disk size.

### Phase 1 — Cluster bootstrap

- [ ] Provision Talos VMs on Proxmox with static IPs and VMID convention.
- [ ] Bootstrap Talos control planes and join workers.
- [ ] Install Cilium, ingress controller, and baseline policies.
- [ ] Validate private access over Tailscale.

### Phase 2 — Platform services

- [ ] Deploy Argo CD (app-of-apps/ApplicationSet pattern).
- [ ] Deploy Longhorn + storage classes.
- [ ] Deploy observability stack.
- [ ] Configure and test backups.

### Phase 3 — App onboarding + external media route

- [ ] Onboard initial app set via Argo CD.
- [ ] Add ingress routes for Tailnet access.
- [ ] Add route from cluster ingress to NAS media service.

### Phase 4 — Hardening/day-2

- [ ] Upgrade playbooks for Talos/K8s/Cilium/Longhorn.
- [ ] Failure drills (node loss, disk loss, restore).
- [ ] Optional Cloudflare tunnel + DNS rollout.

---

<<<<<<< ours
<<<<<<< ours

## 8) Remaining questions to finalize before implementation

1. What is your preferred ingress controller now: **Traefik** (recommended for familiarity) or NGINX?
2. Do you want Cilium in conservative mode first, or full kube-proxy replacement from day 1?
3. What initial Longhorn disk size per worker should we reserve?
4. Which first 5 apps should be onboarded via Argo CD?
5. # What RPO/RTO targets do you want for critical services?

## 8) Remaining confirmations before implementation

1. Confirm the initial **first 5 apps** to onboard after platform baseline.
2. Confirm **RPO/RTO targets** for critical services.
   > > > > > > > # theirs

## 8) Remaining confirmations before implementation

1. Confirm the initial **first 5 apps** to onboard after platform baseline.
2. Confirm **RPO/RTO targets** for critical services.
   > > > > > > > theirs

---

## 9) Immediate next step

<<<<<<< ours
<<<<<<< ours
After you answer Section 8, I will generate the concrete **Phase 0/1 implementation blueprint** with:

- exact VM specs,
- exact IP/VMID table,
- repo folder layout,
- `mise` task skeleton,
- bootstrap command order.
  > > > > > > > # theirs
  > > > > > > >
  > > > > > > > Proceed with repository scaffolding and task automation implementation using `mise`.
  > > > > > > > theirs
  > > > > > > > =======
  > > > > > > > Proceed with repository scaffolding and task automation implementation using `mise`.
  > > > > > > > theirs
