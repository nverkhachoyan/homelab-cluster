#!/usr/bin/env bash
set -euo pipefail

SOURCE_NAMESPACE="${SOURCE_NAMESPACE:-default}"
TARGET_NAMESPACE="${TARGET_NAMESPACE:-media}"
TIMEOUT="${TIMEOUT:-600s}"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

# app|old_pvc_in_source_ns|new_pvc_in_target_ns
MAPPINGS=(
  "filebrowser|filebrowser-db-pvc|filebrowser-db-pvc-lp"
  "jellyfin|jellyfin-config-pvc|jellyfin-config-pvc-lp"
  "jellyseerr|jellyseerr-config-pvc|jellyseerr-config-pvc-lp"
  "kavita|kavita-config-pvc|kavita-config-pvc-lp"
  "prowlarr|prowlarr-config-pvc|prowlarr-config-pvc-lp"
  "qbittorrent|qbit-config-pvc|qbit-config-pvc-lp"
  "radarr|radarr-config-pvc|radarr-config-pvc-lp"
  "readarr|readarr-config-pvc|readarr-config-pvc-lp"
  "sonarr|sonarr-config-pvc|sonarr-config-pvc-lp"
)

scale_if_exists() {
  local ns="$1"
  local app="$2"
  local replicas="$3"

  if kubectl -n "$ns" get deployment "$app" >/dev/null 2>&1; then
    kubectl -n "$ns" scale deployment "$app" --replicas="$replicas"
    if [[ "$replicas" == "1" ]]; then
      kubectl -n "$ns" rollout status "deployment/${app}" --timeout=300s
    fi
  fi
}

migrate_pvc() {
  local app="$1"
  local old_pvc="$2"
  local new_pvc="$3"
  local ts src_pod dst_pod
  ts="$(date +%s)"
  src_pod="migrate-src-${app}-${ts}"
  dst_pod="migrate-dst-${app}-${ts}"

  echo "==> ${app}: ${SOURCE_NAMESPACE}/${old_pvc} -> ${TARGET_NAMESPACE}/${new_pvc}"

  if ! kubectl -n "$SOURCE_NAMESPACE" get pvc "$old_pvc" >/dev/null 2>&1; then
    echo "Skipping ${app}: source PVC ${SOURCE_NAMESPACE}/${old_pvc} not found"
    return
  fi

  if ! kubectl -n "$TARGET_NAMESPACE" get pvc "$new_pvc" >/dev/null 2>&1; then
    echo "Skipping ${app}: target PVC ${TARGET_NAMESPACE}/${new_pvc} not found"
    return
  fi

  # Freeze old and new pods for consistent copy.
  scale_if_exists "$SOURCE_NAMESPACE" "$app" 0
  kubectl -n "$SOURCE_NAMESPACE" wait --for=delete pod -l app="$app" --timeout=120s || true
  scale_if_exists "$TARGET_NAMESPACE" "$app" 0
  kubectl -n "$TARGET_NAMESPACE" wait --for=delete pod -l app="$app" --timeout=120s || true

  cat <<EOF | kubectl -n "$SOURCE_NAMESPACE" apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${src_pod}
spec:
  restartPolicy: Never
  containers:
    - name: copier
      image: alpine:3.20
      command: ["/bin/sh", "-ceu", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /src
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: ${old_pvc}
EOF

  cat <<EOF | kubectl -n "$TARGET_NAMESPACE" apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${dst_pod}
spec:
  restartPolicy: Never
  containers:
    - name: copier
      image: alpine:3.20
      command: ["/bin/sh", "-ceu", "sleep 3600"]
      volumeMounts:
        - name: data
          mountPath: /dst
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: ${new_pvc}
EOF

  kubectl -n "$SOURCE_NAMESPACE" wait --for=condition=Ready "pod/${src_pod}" --timeout="$TIMEOUT"
  kubectl -n "$TARGET_NAMESPACE" wait --for=condition=Ready "pod/${dst_pod}" --timeout="$TIMEOUT"

  # Clear destination PVC before copy to avoid stale files.
  kubectl -n "$TARGET_NAMESPACE" exec "$dst_pod" -- sh -ceu 'find /dst -mindepth 1 -maxdepth 1 -exec rm -rf {} +'

  # Stream tar over kubectl to copy across namespaces.
  kubectl -n "$SOURCE_NAMESPACE" exec "$src_pod" -- sh -ceu 'cd /src && tar -cf - .' \
    | kubectl -n "$TARGET_NAMESPACE" exec -i "$dst_pod" -- sh -ceu 'cd /dst && tar -xpf -'

  kubectl -n "$SOURCE_NAMESPACE" delete pod "$src_pod" --ignore-not-found
  kubectl -n "$TARGET_NAMESPACE" delete pod "$dst_pod" --ignore-not-found

  # Start only the new deployment; old remains scaled down.
  scale_if_exists "$TARGET_NAMESPACE" "$app" 1
}

for mapping in "${MAPPINGS[@]}"; do
  IFS='|' read -r app old_pvc new_pvc <<<"$mapping"
  migrate_pvc "$app" "$old_pvc" "$new_pvc"
done

echo "Migration completed."
echo "Old deployments in ${SOURCE_NAMESPACE} remain scaled to 0."
echo "After validation, you can remove old Longhorn PVCs/PVs."
