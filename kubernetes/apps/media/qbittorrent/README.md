# qBittorrent Notes

Use the web UI at `https://qbittorrent.krapulax.dev`.

Recommended first settings:

-   Downloads:
    -   Default save path: `/downloads`
    -   Keep incomplete torrents in: enabled
    -   Incomplete torrents path: `/incomplete-downloads`
-   Categories:
    -   `tv`
    -   `movies`
-   WebUI:
    -   keep the application credentials enabled
-   Arr integration:
    -   Sonarr or Radarr host: `qbittorrent.media.svc.cluster.local`
    -   port: `8080`
    -   URL base: empty

The pod mounts:

-   `/config` on CephFS
-   `/downloads` on the shared NFS completed-downloads path
-   `/incomplete-downloads` on the shared NFS incomplete-downloads path

Note:

-   this rollout exposes the WebUI but does not yet add dedicated inbound peer port forwarding
-   torrent downloads can still work, but seeding efficiency may be lower until peer-port exposure is added
