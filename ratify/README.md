# Ratify Objects and Constraint Template Documentation

This documentation covers the Ratify configuration objects and the Gatekeeper constraint template used for image signature verification in Kubernetes clusters.

## Overview

Ratify is a verification engine that validates artifacts and their signatures. This demo includes several Kubernetes resources that configure Ratify to work with Azure Key Vault for certificate management and ORAS for artifact storage, using Notation for signature verification.

## Architecture Components

The system consists of:
1. **Gatekeeper Constraint Template** - Defines the admission control policy
2. **Ratify Configuration Objects** - Configure the verification engine
3. **Integration with Azure Services** - For certificate and identity management

---

## Gatekeeper Constraint Template

### File: `ratify-constrainttemplate.yml`

This constraint template integrates Ratify with Gatekeeper to provide admission control for container images.

#### Key Features:

**Template Definition:**
- **Name:** `ratifyverification`
- **Kind:** `RatifyVerification`
- **Target:** `admission.k8s.gatekeeper.sh`

**Verification Logic:**

1. **Image Extraction:** Extracts container images from pod specifications
2. **External Data Call:** Queries the Ratify provider for verification results
3. **Error Handling:** Comprehensive error checking for system and validation errors
4. **Policy Enforcement:** Blocks deployment if verification fails

**Rego Policy Structure:**

```rego
# Extract images from pod spec
images := [img | img = input.review.object.spec.containers[_].image]

# Query Ratify provider
response := external_data({"provider": "ratify-provider", "keys": images})

# Violation conditions:
# 1. System errors
# 2. Image validation errors  
# 3. Failed signature verification
```

**Violation Scenarios:**
- System errors when calling the external data provider
- Validation errors for any images
- Images that fail signature verification (`isSuccess == false`)

---

## Ratify Configuration Objects

### 1. Key Management Provider (`keymanagementprovider-akv.yaml`)

Configures integration with Azure Key Vault for certificate management.

**Specification:**
- **API Version:** `config.ratify.deislabs.io/v1beta1`
- **Kind:** `KeyManagementProvider`
- **Type:** `azurekeyvault`

**Configuration Parameters:**
```yaml
vaultURI: "https://${key_vault_name}.vault.azure.net/"
certificates:
  - name: "${certificate_name}"
    version: "${certificate_version}"
tenantID: "${tenant_id}"
clientID: "${client_id}"
```

**Purpose:** Provides secure access to signing certificates stored in Azure Key Vault for signature verification.

**Template Variables:**
- `${key_vault_name}` - Name of the Azure Key Vault
- `${certificate_name}` - Name of the certificate in Key Vault
- `${certificate_version}` - Specific version of the certificate
- `${tenant_id}` - Azure AD tenant ID
- `${client_id}` - Azure AD application client ID

### 2. Store Configuration (`store-oras.yaml`)

Configures the artifact store using ORAS (OCI Registry as Storage).

**Specification:**
- **API Version:** `config.ratify.deislabs.io/v1beta1`
- **Kind:** `Store`
- **Store Name:** `oras`

**Configuration Parameters:**
```yaml
authProvider:
  name: azureWorkloadIdentity
  clientID: "${client_id}"
cosignEnabled: true
```

**Features:**
- **Azure Workload Identity:** Uses Azure AD for authentication
- **Cosign Support:** Enables Cosign signature format compatibility
- **OCI Registry Integration:** Works with standard container registries

### 3. Verifier Configuration (`verifier-notation.yaml`)

Configures the Notation verifier for signature validation.

**Specification:**
- **API Version:** `config.ratify.deislabs.io/v1beta1`
- **Kind:** `Verifier`
- **Verifier Name:** `notation`
- **Artifact Types:** `application/vnd.cncf.notary.signature`

**Trust Policy Configuration:**
```yaml
trustPolicyDoc:
  version: "1.0"
  trustPolicies:
    - name: default
      registryScopes: ["*"]
      signatureVerification:
        level: strict
      trustStores: ["ca:ca-certs"]
      trustedIdentities:
        - "x509.subject: ${certificate_subject_dn}"
```

**Key Features:**
- **Strict Verification:** Enforces strict signature validation
- **Universal Scope:** Applies to all registry scopes (`"*"`)
- **Certificate Authority Trust:** Uses CA certificates from Key Management Provider
- **Identity Verification:** Validates against specific certificate subject DN

**Template Variables:**
- `${certificate_subject_dn}` - Distinguished Name of the trusted certificate subject

---

## Integration Flow

### 1. Admission Control Process

1. **Pod Creation:** User attempts to create a pod with container images
2. **Gatekeeper Intercept:** Constraint template intercepts the admission request
3. **Image Extraction:** Rego policy extracts container image references
4. **Ratify Query:** External data provider calls Ratify for verification
5. **Policy Decision:** Based on verification results, allow or deny pod creation

### 2. Verification Process

1. **Image Reference:** Ratify receives image reference to verify
2. **Artifact Retrieval:** ORAS store fetches signature artifacts from registry
3. **Certificate Retrieval:** Key Management Provider fetches certificates from Azure Key Vault
4. **Signature Verification:** Notation verifier validates signatures against trust policy
5. **Result Return:** Verification result returned to Gatekeeper

## Security Considerations

### Trust Chain
- **Root of Trust:** Azure Key Vault certificates
- **Identity Management:** Azure Workload Identity for secure access
- **Signature Standards:** CNCF Notary v2 signatures via Notation

### Policy Enforcement
- **Strict Verification:** No unsigned or improperly signed images allowed
- **Comprehensive Error Handling:** System and validation errors block deployment
- **Scope Coverage:** Applies to all registries and namespaces

## Deployment Requirements

### Prerequisites
- Kubernetes cluster with Gatekeeper installed
- Ratify installed and configured as external data provider
- Azure Key Vault with signing certificates
- Azure Workload Identity configured
- Container registry with signed images

### Configuration Steps
1. Deploy Key Management Provider for Azure Key Vault access
2. Deploy Store configuration for ORAS artifact retrieval
3. Deploy Verifier configuration for Notation signature validation
4. Deploy Constraint Template for admission control policy
5. Create Constraint instances to enforce policy

## Troubleshooting

### Common Issues
- **System Errors:** Check Ratify provider connectivity and configuration
- **Validation Errors:** Verify certificate access and trust policy configuration
- **Authentication Failures:** Confirm Azure Workload Identity setup
- **Registry Access:** Ensure proper credentials for container registry access

### Debugging
- Check Ratify logs for detailed verification information
- Verify certificate accessibility in Azure Key Vault
- Test signature verification independently
- Review Gatekeeper constraint violations for specific error messages

## Template Variable Reference

When deploying these configurations, replace the following template variables:

| Variable | Description | Example |
|----------|-------------|---------|
| `${key_vault_name}` | Azure Key Vault name | `my-signing-vault` |
| `${certificate_name}` | Certificate name in Key Vault | `code-signing-cert` |
| `${certificate_version}` | Certificate version | `latest` or specific version |
| `${tenant_id}` | Azure AD tenant ID | `12345678-1234-1234-1234-123456789012` |
| `${client_id}` | Azure AD application client ID | `87654321-4321-4321-4321-210987654321` |
| `${certificate_subject_dn}` | Certificate subject DN | `CN=MyOrg Code Signing,O=MyOrg,C=US` |

This configuration provides a complete image signature verification solution using industry-standard tools and cloud-native security practices.
