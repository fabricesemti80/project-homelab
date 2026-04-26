# Radarr Notes

Use the web UI at `https://radarr.krapulax.dev`.

Recommended first settings:

-   Root folder:
    -   `/media/movies`
-   Download client:
    -   type: `SABnzbd`
    -   host: `sabnzbd.media.svc.cluster.local`
    -   port: `8080`
    -   SSL: `off`
    -   URL base: empty
    -   category: `movies`
    -   API key: copy from the SABnzbd UI
-   Media Management:
    -   keep completed download handling enabled

The pod mounts:

-   `/config` on CephFS
-   `/media` on the shared NFS library
-   `/downloads` on the shared NFS completed-downloads path
