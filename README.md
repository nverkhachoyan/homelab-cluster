# Homelab k3s Cluster

Minimal homelab setup for media workloads

## Stack

- Platform: MetalLB, Traefik, Cloudflared
- Workloads: Radarr, Sonarr, Readarr, Prowlarr, FlareSolverr, Jellyfin, Jellyseerr, Kavita, qBittorrent, Filebrowser
- Network privacy: qBittorrent runs through a Gluetun sidecar using Proton VPN WireGuard and Proton VPN port forwarding
- Storage:
  - Shared media data on NFS (`media-pv` / `media-pvc`)
  - App config PVCs on k3s `local-path`

## Structure

- `kubernetes/platform/`: infrastructure manifests and top-level platform kustomization
- `kubernetes/workloads/`: media namespace, storage, app manifests, and top-level workload kustomization
- `scripts/apply_secrets.sh`: creates Kubernetes Secrets from the `homelab-secrets` 1Password item
- `scripts/render-traefik.sh`: renders the Traefik Helm chart
- `scripts/validate.sh`: renders platform, Traefik, and workload manifests
- `scripts/deploy.sh`: ordered deployment workflow

## Workflow

```sh
scripts/apply_secrets.sh
scripts/validate.sh
scripts/deploy.sh
```

Traefik is rendered directly with Helm instead of through Kustomize because the
current Kustomize Helm integration calls a Helm v3-only flag and fails with Helm
v4.
