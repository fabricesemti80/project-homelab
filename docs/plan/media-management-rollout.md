# Media Management Rollout

## Phase 1

-   [x] Decide to reuse the `media` namespace for management services
-   [x] Choose `sabnzbd` instead of `nzbget` for the first downloader rollout
-   [x] Keep NFS for media paths and CephFS for app configs
-   [x] Defer cross-app API-key automation until base services are stable

## Implementation

-   [x] Add architecture notes for the media-management stack
-   [x] Scaffold `sabnzbd` application manifests
-   [x] Scaffold `sonarr` application manifests
-   [x] Scaffold `prowlarr` application manifests
-   [x] Scaffold `recyclarr` application manifests
-   [x] Add Argo CD applications for the first services
-   [ ] Sync Argo CD and verify workloads become healthy

## Operator Steps

-   [ ] Confirm `/media/downloads/complete` exists on the NFS server
-   [ ] Confirm `/media/downloads/incomplete` exists on the NFS server
-   [ ] Open `https://sabnzbd.krapulax.dev`
-   [ ] Complete SABnzbd first-run setup
-   [ ] Add Usenet server details in the SABnzbd UI unless a later Doppler-backed bootstrap is introduced
-   [ ] Open `https://sonarr.krapulax.dev`
-   [ ] Configure Sonarr root folders and downloader integration
-   [ ] Open `https://prowlarr.krapulax.dev`
-   [ ] Add indexers in Prowlarr
-   [ ] Add Sonarr as an app in Prowlarr using `http://sonarr.media.svc.cluster.local:8989`
-   [ ] Add `SONARR_API_KEY` to Doppler for Recyclarr
-   [ ] Verify Recyclarr syncs Sonarr quality settings

## Validation

-   [ ] `kubectl get pods -n media`
-   [ ] `kubectl get pvc -n media`
-   [ ] `kubectl describe pod -n media -l app.kubernetes.io/name=sabnzbd`
-   [ ] `kubectl describe pod -n media -l app.kubernetes.io/name=sonarr`
-   [ ] `kubectl describe pod -n media -l app.kubernetes.io/name=prowlarr`
-   [ ] `kubectl describe pod -n media -l app.kubernetes.io/name=recyclarr`
-   [ ] `kubectl exec -n media deploy/sabnzbd -- grep '^host_whitelist' /config/sabnzbd.ini`
-   [ ] `curl -I https://sabnzbd.krapulax.dev/`
-   [ ] `curl -I https://sonarr.krapulax.dev/`
-   [ ] `curl -I https://prowlarr.krapulax.dev/`
-   [ ] `kubectl logs -n media deploy/recyclarr --tail=100`

## Follow-Up

-   [ ] Add `radarr`
-   [ ] Design and implement API-key bootstrap automation
