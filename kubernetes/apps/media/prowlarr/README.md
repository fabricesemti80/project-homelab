# Prowlarr Notes

Use the web UI at `https://prowlarr.krapulax.dev`.

Recommended first settings:

-   Applications:
    -   add Sonarr
    -   URL: `http://sonarr.media.svc.cluster.local:8989`
    -   sync level: standard or full, depending on preference
    -   API key: copy from the Sonarr UI
-   Download clients:
    -   if needed later, add SABnzbd at `http://sabnzbd.media.svc.cluster.local:8080`
-   Indexers:
    -   add your Usenet indexers here and sync them to Sonarr

The pod mounts:

-   `/config` on CephFS
