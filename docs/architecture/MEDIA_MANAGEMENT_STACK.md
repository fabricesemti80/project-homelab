# Media Management Stack

## Objective

Add media-management services that feed Jellyfin while preserving the existing storage split:

-   CephFS for application-owned config and state
-   NFS for shared media library and download paths
-   small, reversible rollout starting with `sabnzbd` and `sonarr`

## Scope

Initial rollout includes:

-   `sabnzbd`
-   `sonarr`
-   `prowlarr`

Deferred until the first two apps are stable:

-   `radarr`
-   API-key automation between services

## Namespace Decision

-   Reuse the existing `media` namespace

Rationale:

-   these services ultimately exist to source content for Jellyfin
-   the namespace already contains the shared media-library claim and routing patterns
-   it avoids cross-namespace duplication for the first rollout

## Storage Model

-   Each app gets its own CephFS-backed PVC for `/config`
-   Shared media content remains on the NFS export at `10.0.40.2:/media`
-   The existing `media-library-pvc` remains the shared claim for the full library mount
-   Download paths are mounted from the same NFS claim using subpaths under `/media/downloads`

Planned pod paths:

-   `sonarr`
    -   `/config` on CephFS
    -   `/media` on NFS
    -   `/downloads` on NFS subpath `downloads`
-   `sabnzbd`
    -   `/config` on CephFS
    -   `/media` on NFS
    -   `/downloads` on NFS subpath `downloads/complete`
    -   `/incomplete-downloads` on NFS subpath `downloads/incomplete`
-   `prowlarr`
    -   `/config` on CephFS

## API-Key Automation Direction

The long-term goal is to automate cross-service integration, especially for Prowlarr, Sonarr, and Radarr.

For the initial rollout, do not assume app API keys can be cleanly injected through environment variables. Many of these applications generate and own their API keys internally.

Recommended future pattern:

-   deploy apps first
-   add a bootstrap or reconciliation job that:
    -   waits for app readiness
    -   discovers or rotates API keys through supported APIs
    -   configures downstream integrations

This avoids coupling runtime app internals to guessed static secrets in Doppler.

## Security Notes

-   Public ingress is acceptable temporarily for test access, but each app still needs its own application authentication enabled in the UI
-   SABnzbd server credentials should not be committed; if later automated, source them from Doppler
-   The NFS-backed media library remains shared state and should be treated as retained data

## Assumptions

-   `/media/downloads`
-   `/media/downloads/complete`
-   `/media/downloads/incomplete`

already exist or can be created on the NFS server before workloads start.

## Validation

-   Argo sync succeeds for the deployed apps
-   PVCs bind on CephFS
-   pods mount both CephFS config and NFS library paths
-   `sabnzbd` serves its UI and can write test files under `/downloads`
-   `sonarr` serves its UI and can see both `/media` and `/downloads`
-   `prowlarr` serves its UI and can reach Sonarr over the in-cluster service

## Rollback

-   Delete the `sabnzbd`, `sonarr`, and `prowlarr` Argo applications
-   Remove their HTTPRoutes
-   Delete their CephFS PVCs if app config should be discarded
-   Retain NFS media content and download directories
