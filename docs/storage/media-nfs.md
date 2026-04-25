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
    -   is exposed at `https://jelly.krapulax.dev` via the shared `external.krapulax.dev` Cloudflare tunnel target and the `envoy-external` Gateway

## Assumptions

-   The NFS server `10.0.40.2` is reachable from the cluster nodes
-   The export path `/media` already exists and contains the current shared library
-   Permissions on the export allow Jellyfin to read the media files as configured
-   `external.krapulax.dev` already terminates through the Cloudflare tunnel to the cluster `envoy-external` Gateway
-   external-dns is reconciling `HTTPRoute` hostname annotations into Cloudflare DNS records

## Validation

After Argo syncs:

```bash
kubectl get pv media-library-pv
kubectl get pvc -n media media-library-pvc
kubectl get pods -n media
kubectl describe pod -n media -l app.kubernetes.io/name=jellyfin
kubectl get httproute -n media jellyfin -o yaml
```

Then verify public routing:

```bash
kubectl get httproute -n media jellyfin -o jsonpath='{.metadata.annotations}'
dig +short jelly.krapulax.dev
curl -I https://jelly.krapulax.dev/
```

If the pod starts but libraries are empty, verify NFS connectivity and path contents from the storage server side.

If the hostname still returns `404`, confirm the DNS record resolves to `external.krapulax.dev` rather than a stale direct tunnel target.

## Rollback

-   Remove the external-dns annotations from `kubernetes/apps/media/jellyfin/config/http-route.yaml`
-   Re-sync the Jellyfin Argo CD application so external-dns can withdraw the record
-   Restore the prior DNS mapping only if a direct Cloudflare tunnel route is intentionally reintroduced
