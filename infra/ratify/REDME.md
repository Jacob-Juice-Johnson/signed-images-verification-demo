# Ratify Azure Policy Terraform Configuration

This Terraform configuration creates an Azure Policy definition and assigns it to an existing AKS cluster for Ratify image verification.

## Prerequisites

- An existing AKS cluster
- Azure CLI installed and authenticated
- Terraform installed
- Appropriate Azure permissions to create policy definitions and assignments

## Files

- `policy.tf` - Policy definition and assignment resources
- `kubernetes.tf` - Kubernetes resources (Ratify Store configuration)
- `ratify-policy.json` - Azure Policy JSON definition (makes it easy to read and modify)
- `variables.tf` - Input variables
- `data.tf` - Data sources for existing AKS cluster
- `providers.tf` - Terraform providers configuration (Azure and Kubernetes)
- `outputs.tf` - Output values
- `main.tf` - Main entry point (currently just documentation)
- `terraform.tfvars.example` - Example variable values

## Usage

1. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your actual values:
   ```hcl
   resource_group_name = "your-resource-group"
   aks_cluster_name   = "your-aks-cluster-name"
   identity_name      = "your-workload-identity-name"
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan the deployment:
   ```bash
   terraform plan
   ```

5. Apply the configuration:
   ```bash
   terraform apply
   ```

## What this creates

1. **Azure Policy Definition**: A custom policy definition based on the Ratify default policy that validates signed container images
2. **Resource Policy Assignment**: Assigns the policy to your existing AKS cluster
3. **Ratify Store Configuration**: Creates a Kubernetes Store resource for ORAS with Azure Workload Identity authentication

## Policy Parameters

- `policy_effect`: Effect of the policy (Deny, Audit, or Disabled) - default: "Deny"
- `excluded_namespaces`: Namespaces to exclude from policy evaluation - default: ["kube-system", "gatekeeper-system"]
- `namespaces`: Namespaces to include (empty list means all namespaces) - default: []
- `label_selector`: Kubernetes label selector for targeting specific resources - default: {}

## Outputs

After deployment, the following values are output:
- `policy_definition_id`: The ID of the created policy definition
- `policy_assignment_id`: The ID of the policy assignment
- `aks_cluster_id`: The ID of the target AKS cluster
- `policy_definition_name`: The name of the policy definition

## Cleanup

To remove the policy assignment and definition:
```bash
terraform destroy
```