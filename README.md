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
kubectl create namespace demo
kubectl run demo-signed --image=ratifyacrdemo009.azurecr.io/demo-signed-image:latest --namespace demo
kubectl run demo-unsigned --image=ratifyacrdemo009.azurecr.io/demo-unsigned-image:latest --namespace demo
```

8. Advanced testing
(Run the github actions worklow and approve the deployment step)

I have the github actions to do the following with matrixes. There are 3 artifacts that are in our ACR that we use during deployment. We have 4 scenarios that we test. The comments indicate which ones will fail and why.

```
matrix:
    app_type:
        # 1 will fail on helm verify
        - name: 1-all-unsigned
        image_name: "ratifyacrdemo009.azurecr.io/demo-unsigned-image:latest"
        helm_chart: "demo-app-unsigned"
        test_image: "busybox:latest"
        # 2 will fail on test, helm will deploy but image will pod will not be there (fails on helm deploy)
        - name: 2-helm-signed
        image_name: "ratifyacrdemo009.azurecr.io/demo-unsigned-image:latest"
        helm_chart: "demo-app-signed"
        test_image: "busybox:latest"
        # 3 will fail on test
        - name: 3-app-image-signed
        image_name: "ratifyacrdemo009.azurecr.io/demo-signed-image:latest"
        helm_chart: "demo-app-signed"
        test_image: "busybox:latest"
        # 4 will succeed
        - name: 4-all-signed
        image_name: "ratifyacrdemo009.azurecr.io/demo-signed-image:latest"
        helm_chart: "demo-app-signed"
        test_image: "ratifyacrdemo009.azurecr.io/busybox:latest"
```

View the logs of deployments
```
# 1
# View GitHub Actions log to verify helm chart was not signed causing this failure

# 2
# View all events in namespace to confirm helm-signed-2 failed due to image not signed
kubectl get events --sort-by='.metadata.creationTimestamp' -n demo | grep helm-signed-2

# 3 
# Verify app-image-signed-3 pod is up and running
# View GitHub Actions log to verify test failed due to image not signed
kubectl get pods -n demo | grep app-image-signed-3
helm test app-image-signed-3 --logs -n demo # Further verify test never ran

# 4
# See pod is up and test pod ran and completed successfully
kubectl get pods -n demo | grep all-signed-4
helm test all-signed-4 --logs -n demo
```

9. Cleanup
(Cleanup to not incur costs)
```
cd infra/ratify
terraform destroy -auto-approve

cd ../platform
terraform destroy -auto-approve

cd ../identity
terraform destroy -auto-approve
```