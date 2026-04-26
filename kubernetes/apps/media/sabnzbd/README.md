# SABnzbd Notes

Use the web UI at `https://sabnzbd.krapulax.dev`.

Recommended first settings:

-   Folders:
    -   completed download folder: `/downloads`
    -   temporary download folder: `/incomplete-downloads`
    -   if SABnzbd shows paths under `/config/Downloads/...`, update them to the two paths above and restart the job or retry it
-   API:
    -   enable the API
    -   keep the API key handy for Sonarr and later Prowlarr
-   Security:
    -   add a SABnzbd username/password in the UI

Usenet server details can be added in the UI for now.

The pod mounts:

-   `/config` on CephFS
-   `/media` on the shared NFS library
-   `/downloads` on `downloads/complete`
-   `/incomplete-downloads` on `downloads/incomplete`
