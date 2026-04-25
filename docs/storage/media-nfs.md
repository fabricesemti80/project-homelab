# Media NFS Storage

This cluster can consume the existing media library over NFS for workloads such as Jellyfin.

## Design

-   **Source of truth for media files**: existing NFS export at `10.0.40.2:/media`
-   **Kubernetes access model**: static `PersistentVolume` plus namespace-local `PersistentVolumeClaim`
-   **Retention goal**: keep the underlying media library intact even if an app or PVC is deleted
-   **Reclaim policy**: `Retain`
-   **App state split**:
    -   NFS is for the large retained media library mounted at `/data`
    -   CephFS remains the default for cluster-owned app state such as Jellyfin config and cache

## Current Consumer

-   `media/jellyfin`
    -   mounts the static NFS library claim at `/data`
    -   uses CephFS PVCs for `/config` and `/cache`
    -   is exposed at `https://jelly.krapulax.dev`

## Assumptions

-   The NFS server `10.0.40.2` is reachable from the cluster nodes
-   The export path `/media` already exists and contains the current shared library
-   Permissions on the export allow Jellyfin to read the media files as configured
-   Cloudflare tunnel ingress for `*.krapulax.dev` already routes to the cluster

## Validation

After Argo syncs:

```bash
kubectl get pv media-library-pv
kubectl get pvc -n media media-library-pvc
kubectl get pods -n media
kubectl describe pod -n media -l app.kubernetes.io/name=jellyfin
```

If the pod starts but libraries are empty, verify NFS connectivity and path contents from the storage server side.
