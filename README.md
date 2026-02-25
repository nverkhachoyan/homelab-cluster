# Homelab k3s Cluster

Minimal homelab setup for media workloads

## Stack

- Platform: MetalLB, Traefik, Cloudflared
- Workloads: Radarr, Sonarr, Readarr, Prowlarr, FlareSolverr, Jellyfin, Jellyseerr, Kavita, qBittorrent, Filebrowser
- Storage:
  - Shared media data on NFS (`media-pv` / `media-pvc`)
  - App config PVCs on k3s `local-path`

## Structure

- `kubernetes/platform/`: infrastructure manifests and top-level platform kustomization
- `kubernetes/workloads/`: media namespace, storage, app manifests, and top-level workload kustomization
- `scripts/deploy.sh`: ordered deployment workflow
