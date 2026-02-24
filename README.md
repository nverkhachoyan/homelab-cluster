# Homelab k3s Cluster

Minimal homelab setup focused on media workloads.

## Stack

- Platform: MetalLB, Traefik, Cloudflared
- Workloads: Radarr, Sonarr, Readarr, Prowlarr, FlareSolverr, Jellyfin, Jellyseerr, Kavita, qBittorrent, Filebrowser
- Storage:
  - Shared media data on NFS (`media-pv` / `media-pvc`)
  - App config PVCs on k3s `local-path`

Removed from this repo:

- ArgoCD
- Longhorn
- Homepage

## Structure

- `kubernetes/platform/`: infrastructure manifests and top-level platform kustomization
- `kubernetes/workloads/`: media namespace, storage, app manifests, and top-level workload kustomization
- `scripts/deploy.sh`: ordered deployment workflow
- `scripts/generate_secrets.sh`: generates `scripts/secrets_cmd.sh` to apply secrets in `media` and `cloudflared`
- `scripts/migrate_longhorn_to_local_path.sh`: one-time PVC migration helper

## Deploy

Prerequisites:

- `kubectl`
- `helm` (used by kustomize for Traefik chart rendering)
- outbound network access to fetch upstream chart/base manifests

1. Generate and run secrets script:

```sh
./scripts/generate_secrets.sh
./scripts/secrets_cmd.sh
```

2. Deploy platform + workloads:

```sh
./scripts/deploy.sh
```

## Longhorn -> local-path migration (one-time)

This repo uses new `*-lp` config PVC names. To preserve existing app data from old Longhorn PVCs:

1. Apply updated manifests first so new `*-lp` PVCs exist.
2. Run migration script:

```sh
./scripts/migrate_longhorn_to_local_path.sh
```

3. Validate app configs, then remove old Longhorn PVCs/PVs and uninstall Longhorn from the cluster.

## Validation

```sh
kubectl kustomize --enable-helm kubernetes/platform >/dev/null
kubectl kustomize kubernetes/workloads >/dev/null
kubectl -n media get deploy,pvc,ingress
kubectl -n cloudflared get deploy
```
