# Node.js Helm Chart

A generic Helm chart for deploying Node.js or Bun applications with optional persistence, secrets, and ingress.

## Installation

```bash
helm repo add enking https://enyineer.github.io/helm/
helm install my-app enking/nodejs -f values.yaml
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Docker image repository | `""` (required) |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `imagePullSecrets` | Image pull secrets | `[]` |
| `containerPort` | Application port | `3000` |
| `env` | Environment variables (non-sensitive) | `{}` |
| `secrets` | Secret values (auto base64 encoded) | `{}` |
| `existingSecret` | Use existing secret name | `""` |
| `persistence.enabled` | Enable persistence | `false` |
| `persistence.mountPath` | Volume mount path | `/data` |
| `persistence.size` | PVC size | `1Gi` |
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class | `""` |
| `ingress.host` | Hostname | `""` |
| `ingress.tls.enabled` | Enable TLS | `false` |
