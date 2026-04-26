# Recyclarr Notes

Recyclarr syncs TRaSH-style quality settings into Sonarr.

Required Doppler secret for the first rollout:

-   `SONARR_API_KEY`

Optional later secrets:

-   `RADARR_API_KEY`

The deployment uses:

-   Sonarr URL: `http://sonarr.media.svc.cluster.local:8989`
-   schedule: `0 4 * * *`

Validation:

-   check the pod logs for successful Sonarr sync runs
-   confirm Sonarr quality profiles and custom formats update as expected
