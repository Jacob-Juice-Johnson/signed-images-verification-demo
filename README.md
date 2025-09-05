# signed-images-verification-demo

## How to use demo
1. Deploy Azure SPN for build-push-and-sign workflow
(SPN, User Permissions)
```
cd infra/identity
terraform init
terraform apply -auto-approve
```

2. Deploy Platform Infrastructure
(RG, KV, Self Signed Cert, AKS, ACR, Managed Identity, and Ratify Helm Chart)
```
cd infra/platform
terraform init
terraform apply -auto-approve
```

3. Delete auto created ratify resources in AKS
```
az aks get-credentials --resource-group {RG-name} --name {AKS-name} --overwrite-existing
kubectl delete Verifier verifier-notation
kubectl delete Store store-oras
```

4. Deploy Ratify Policies
(Ratify verifier, Ratify Store Oras, Ratify Key Management Provider, Audit NS, Azure Ratify Policy Definition, Azure Ratify Policy Assignment Deny, Azure Ratify Policy Assignment Audit)
```
cd infra/ratify
terraform init
terraform apply -auto-approve
```

5. Set up your Azure credentials as a GitHub secret named `AZURE_CREDENTIALS` in your repo
```
{
    "clientSecret":  "look into local state file (not secure but good for demo lol)",
    "subscriptionId":  "abaecb33-47b5-451a-abce-59549340ac7b",
    "tenantId":  "1208b425-3044-488d-b6b5-7568e48f624e",
    "clientId":  "e4a623bc-6818-471c-bbad-cc62dca20a12"
}
```

6. Run build and deploy github action
(Builds, pushes, and signs demo-signed-image and build and pushes demo-unsigned-image)

7. Test deploying images
(Deploy signed image should work, deploy unsigned image should be denied)

Verify the gatekeeper resource was deployed (Gatekeeper polls azure policy every 15 minutes)
```
kubectl get constraintTemplate ratifyverification
```

```
sudo az acr login --name {acr-name}
kubectl create namespace test
kubectl run demo-signed --image=ratifyacrdemo009.azurecr.io/demo-signed-image:latest --namespace test
kubectl run demo-unsigned --image=ratifyacrdemo009.azurecr.io/demo-unsigned-image:latest --namespace test
```