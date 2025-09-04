# Infrastructure Diagram

This Mermaid diagram shows the Azure resources created by this Terraform configuration for a signed container images verification demo.

```mermaid
graph TB
    %% Azure Resource Group
    RG[Azure Resource Group<br/>azurerm_resource_group.rg]
    
    %% Container Registry
    ACR[Azure Container Registry<br/>azurerm_container_registry.registry<br/>SKU: Basic]
    
    %% Key Vault
    KV[Azure Key Vault<br/>azurerm_key_vault.kv<br/>SKU: Standard<br/>RBAC Enabled]
    
    %% AKS Cluster
    AKS[Azure Kubernetes Service<br/>azurerm_kubernetes_cluster.aks<br/>v1.30.6<br/>Workload Identity Enabled<br/>OIDC Issuer Enabled]
    
    %% User Assigned Identity
    UAI[User Assigned Identity<br/>azurerm_user_assigned_identity.identity]
    
    %% Key Vault Certificate
    CERT[Key Vault Certificate<br/>azurerm_key_vault_certificate.ratify-cert<br/>Self-signed RSA 2048<br/>12 months validity]
    
    %% Federated Identity Credential
    FIC[Federated Identity Credential<br/>azurerm_federated_identity_credential<br/>workload-identity-credential]
    
    %% Helm Release
    HELM[Helm Release - Ratify<br/>helm_release.ratify<br/>Namespace: gatekeeper-system]
    
    %% Data Sources
    CLIENT_CONFIG[Azure Client Config<br/>data.azurerm_client_config.current]
    AAD_CONFIG[Azure AD Client Config<br/>data.azuread_client_config.current]
    
    %% Role Assignments
    RA1[Role Assignment<br/>ACR Pull<br/>Identity → ACR]
    RA2[Role Assignment<br/>ACR Pull<br/>AKS Kubelet → ACR]
    RA3[Role Assignment<br/>Key Vault Secrets User<br/>Identity → Key Vault]
    RA4[Role Assignment<br/>Key Vault Administrator<br/>Current User → Key Vault]
    
    %% Relationships
    RG --> ACR
    RG --> KV
    RG --> AKS
    RG --> UAI
    RG --> FIC
    
    KV --> CERT
    
    UAI -.-> RA1
    RA1 -.-> ACR
    
    AKS -.-> RA2
    RA2 -.-> ACR
    
    UAI -.-> RA3
    RA3 -.-> KV
    
    CLIENT_CONFIG -.-> RA4
    RA4 -.-> KV
    
    AKS --> FIC
    UAI --> FIC
    
    HELM --> AKS
    HELM --> UAI
    HELM --> FIC
    HELM --> RA3
    
    CLIENT_CONFIG -.-> KV
    AAD_CONFIG -.-> KV
    
    %% Styling
    classDef resource fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef identity fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef security fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef roleAssignment fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef data fill:#fafafa,stroke:#424242,stroke-width:2px
    
    class RG,ACR,AKS resource
    class UAI,FIC identity
    class KV,CERT security
    class RA1,RA2,RA3,RA4 roleAssignment
    class CLIENT_CONFIG,AAD_CONFIG data
    class HELM security
```

## Resource Summary

### Core Infrastructure
- **Resource Group**: Container for all resources
- **Azure Container Registry (ACR)**: Stores container images
- **Azure Kubernetes Service (AKS)**: Kubernetes cluster with workload identity
- **Azure Key Vault**: Stores certificates and secrets

### Identity & Security
- **User Assigned Identity**: Managed identity for workload identity authentication
- **Federated Identity Credential**: Links AKS service account to managed identity
- **Key Vault Certificate**: Self-signed certificate for Ratify (container image verification)

### RBAC Assignments
- **ACR Pull**: Allows identity and AKS to pull images from registry
- **Key Vault Secrets User**: Allows identity to read secrets from Key Vault
- **Key Vault Administrator**: Gives current user admin access to Key Vault

### Application
- **Helm Release (Ratify)**: Container image verification tool deployed to AKS

### Data Sources
- **Azure Client Config**: Current Azure client configuration
- **Azure AD Client Config**: Current Azure AD client configuration

This infrastructure supports a container image signing and verification workflow using Ratify in an AKS cluster with workload identity authentication to Azure Key Vault for certificate access.
