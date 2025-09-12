# Signed Images Verification Demo

A demonstration of container image signing and verification workflows using Azure Container Registry, Azure Kubernetes Service, and Ratify.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Testing](#testing)
- [Advanced Testing](#advanced-testing)
- [Cleanup](#cleanup)

## Architecture Overview

This demo consists of two main components: the build and push workflow, and the deployment verification workflow.

### Signing Architecture

The signing architecture is responsible for building, pushing, and signing container images to Azure Container Registry. The architecture looks like this:

![Signing Architecture Diagram](docs/signing-architecture.svg)

### Deployment Verification Architecture

The deployment verification architecture is responsible for verifying that images being deployed to an AKS cluster are signed. The architecture looks like this:

![Deployment Verification Architecture Diagram](docs/deployment-diagram.png)

## Prerequisites

- Azure CLI installed and configured
- Terraform installed
- kubectl installed
- Docker installed
- Access to an Azure subscription
- GitHub repository with Actions enabled

## Setup Instructions

### Step 1: Login to Azure CLI

```bash
az login
```

### Step 2: Deploy Azure Service Principal

Deploy the Azure Service Principal for the build-push-and-sign workflow:

```bash
cd infra/identity
terraform init
terraform apply -auto-approve
```

### Step 3: Deploy Platform Infrastructure

Deploy the platform infrastructure including Resource Group, Key Vault, Self-Signed Certificate, AKS, ACR, Managed Identity, and Ratify Helm Chart:

```bash
cd infra/platform
terraform init
terraform apply -auto-approve
```

### Step 4: Clean Up Auto-Created Ratify Resources

Remove the automatically created Ratify resources in AKS:

```bash
# Get AKS credentials
az aks get-credentials --resource-group {RG-name} --name {AKS-name} --overwrite-existing

# Delete auto-created resources
kubectl delete Verifier verifier-notation
kubectl delete Store store-oras
```

### Step 5: Deploy Ratify Policies

Deploy Ratify policies including verifier, store, key management provider, and Azure policies:

```bash
cd infra/ratify
terraform init
terraform apply -auto-approve
```

### Step 6: Configure GitHub Secrets

Set up your Azure credentials as a GitHub secret named `AZURE_CREDENTIALS` in your repository:

```json
{
    "clientSecret": "look into local state file (not secure but good for demo lol)",
    "subscriptionId": "abaecb33-47b5-451a-abce-59549340ac7b",
    "tenantId": "1208b425-3044-488d-b6b5-7568e48f624e",
    "clientId": "e4a623bc-6818-471c-bbad-cc62dca20a12"
}
```

### Step 7: Run Build and Deploy GitHub Action

Execute the GitHub Action workflow to build, push, and sign the demo images:
- `demo-signed-image` (signed)
- `demo-unsigned-image` (unsigned)

## Testing

### Basic Image Deployment Test

1. **Verify Gatekeeper resource deployment** (Gatekeeper polls Azure Policy every 15 minutes):
   ```bash
   kubectl get constraintTemplate ratifyverification
   ```

2. **Test signed and unsigned image deployment**:
   ```bash
   # Login to ACR
   sudo az acr login --name {acr-name}
   
   # Create demo namespace
   kubectl create namespace demo
   
   # Deploy signed image (should succeed)
   kubectl run demo-signed --image=ratifyacrdemo009.azurecr.io/demo-signed-image:latest --namespace demo
   
   # Deploy unsigned image (should be denied)
   kubectl run demo-unsigned --image=ratifyacrdemo009.azurecr.io/demo-unsigned-image:latest --namespace demo
   ```

## Advanced Testing

The GitHub Actions workflow includes a matrix strategy with four test scenarios:

| Scenario | Name | Image | Helm Chart | Test Image | Expected Result |
|----------|------|-------|------------|------------|-----------------|
| 1 | `1-all-unsigned` | demo-unsigned-image | demo-app-unsigned | busybox:latest | ❌ Fails on Helm verify |
| 2 | `2-helm-signed` | demo-unsigned-image | demo-app-signed | busybox:latest | ❌ Fails on Helm deploy |
| 3 | `3-app-image-signed` | demo-signed-image | demo-app-signed | busybox:latest | ❌ Fails on test |
| 4 | `4-all-signed` | demo-signed-image | demo-app-signed | demo busybox:latest | ✅ Succeeds |

### Viewing Test Results

```bash
# Scenario 1: Check GitHub Actions log for Helm chart signature verification failure

# Scenario 2: View events to confirm failure due to unsigned image
kubectl get events --sort-by='.metadata.creationTimestamp' -n demo | grep helm-signed-2

# Scenario 3: Verify pod is running but test failed
kubectl get pods -n demo | grep app-image-signed-3
helm test app-image-signed-3 --logs -n demo

# Scenario 4: Verify successful deployment and test
kubectl get pods -n demo | grep all-signed-4
helm test all-signed-4 --logs -n demo
```

## Cleanup

To avoid incurring costs, clean up the resources in reverse order:

```bash
# Clean up Ratify policies
cd infra/ratify
terraform destroy -auto-approve

# Clean up platform infrastructure
cd ../platform
terraform destroy -auto-approve

# Clean up identity resources
cd ../identity
terraform destroy -auto-approve
```
