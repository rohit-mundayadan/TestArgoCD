# ArgoCD Image Updater Test Setup

This repository contains a Helm chart and ArgoCD ApplicationSet for testing ArgoCD Image Updater functionality with Rancher Desktop's local registry.

## Project Structure

```
TestArgoCD/
├── helm-chart/              # Helm chart for the test application
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── _helpers.tpl
├── argocd/                  # ArgoCD configuration
│   └── applicationset.yaml
├── Dockerfile               # Sample Dockerfile for testing
└── README.md               # This file
```

## Configuration Details

- **Image Repository**: `localhost:5000/testapp/argo-cd-test`
- **Image Tag Format**: `SEMVER-dev.GITHASH` (e.g., `1.0.0-dev.g0c85fbc`)
- **Update Strategy**: Semver with constraint `~1.0` (updates to any 1.0.x version)
- **Registry**: Rancher Desktop's local Docker registry
- **Deployment**: Local filesystem (no Git repository)

## Prerequisites

1. Rancher Desktop with Kubernetes enabled
2. ArgoCD installed in your cluster
3. ArgoCD Image Updater installed and configured
4. Local Docker registry accessible at `localhost:5000`

## Setup Instructions

### Step 1: Build and Push Initial Image

```bash
# Build the initial image
docker build -t localhost:5000/testapp/argo-cd-test:1.0.0-dev.g0c85fbc .

# Push to local registry
docker push localhost:5000/testapp/argo-cd-test:1.0.0-dev.g0c85fbc
```

### Step 2: Deploy ApplicationSet to ArgoCD

```bash
# Apply the ApplicationSet
kubectl apply -f argocd/applicationset.yaml

# Verify the ApplicationSet was created
kubectl get applicationset -n argocd

# Check the generated Application
kubectl get application -n argocd
```

### Step 3: Verify Deployment

```bash
# Check if the application is synced
kubectl get application argo-cd-test -n argocd

# Check the pods in default namespace
kubectl get pods -n default

# Check the deployment
kubectl get deployment -n default

# View the service
kubectl get svc -n default
```

### Step 4: Test Image Updater

Build and push a new version to test the image updater:

```bash
# Build a new version (increment patch version)
docker build -t localhost:5000/testapp/argo-cd-test:1.0.1-dev.g1a2b3c4 .

# Push the new version
docker push localhost:5000/testapp/argo-cd-test:1.0.1-dev.g1a2b3c4
```

### Step 5: Monitor Image Updater

```bash
# Watch the image updater logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater -f

# Check if the application was updated
kubectl get application argo-cd-test -n argocd -o yaml | grep image:

# Verify the deployment is using the new image
kubectl describe deployment -n default | grep Image:
```

## Image Updater Configuration

The ApplicationSet includes the following Image Updater annotations:

- `argocd-image-updater.argoproj.io/image-list`: Specifies the image to track
- `argocd-image-updater.argoproj.io/testapp.update-strategy`: Uses semver strategy with `~1.0` constraint
- `argocd-image-updater.argoproj.io/testapp.allow-tags`: Regex pattern to match tags in format `1.0.X-dev.gHASH`
- `argocd-image-updater.argoproj.io/write-back-method`: Set to `argocd` for direct Application updates
- `argocd-image-updater.argoproj.io/testapp.force-update`: Forces update check

## Testing Different Versions

To test the image updater with different versions:

```bash
# Version 1.0.2
docker build -t localhost:5000/testapp/argo-cd-test:1.0.2-dev.gabc1234 .
docker push localhost:5000/testapp/argo-cd-test:1.0.2-dev.gabc1234

# Version 1.0.3
docker build -t localhost:5000/testapp/argo-cd-test:1.0.3-dev.gdef5678 .
docker push localhost:5000/testapp/argo-cd-test:1.0.3-dev.gdef5678
```

The image updater should automatically detect and update to the latest version matching the semver constraint.

## Troubleshooting

### Check Image Updater Status

```bash
# View image updater logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-image-updater --tail=100

# Check Application annotations
kubectl get application argo-cd-test -n argocd -o yaml
```

### Verify Registry Access

```bash
# Test if registry is accessible
curl http://localhost:5000/v2/_catalog

# List tags for the test image
curl http://localhost:5000/v2/testapp/argo-cd-test/tags/list
```

### Force Image Updater to Run

```bash
# Restart image updater to force a check
kubectl rollout restart deployment argocd-image-updater -n argocd
```

### Check Application Sync Status

```bash
# Get detailed application status
kubectl describe application argo-cd-test -n argocd

# Check sync status
argocd app get argo-cd-test
```

## Notes

- The image updater runs periodically (default: every 2 minutes)
- With `write-back-method: argocd`, changes are made directly to the Application spec in ArgoCD
- The `force-update` annotation ensures the updater checks for updates even if the current image is recent
- The semver constraint `~1.0` means it will update to any `1.0.x` version but not `1.1.0` or higher

## Cleanup

To remove the test application:

```bash
# Delete the ApplicationSet
kubectl delete -f argocd/applicationset.yaml

# Verify cleanup
kubectl get application -n argocd
kubectl get pods -n default
