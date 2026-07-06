# Traefik

Traefik is rendered from the upstream Helm chart by `scripts/render-traefik.sh`.

It intentionally stays outside the platform kustomization because Kustomize's
Helm integration calls a Helm v3-only flag and breaks with Helm v4.
