# Trust Policy Configuration Guide

This document explains trust policies for container image signature verification, including a detailed breakdown of the settings in `demo-trustpolicy.json`.

## Table of Contents
- [What is a Trust Policy?](#what-is-a-trust-policy)
- [Trust Policy Structure](#trust-policy-structure)
- [Configuration Settings Explained](#configuration-settings-explained)
- [Analysis of demo-trustpolicy.json](#analysis-of-demo-trustpolicyjson)
- [Best Practices](#best-practices)
- [Common Use Cases](#common-use-cases)

## What is a Trust Policy?

A trust policy is a configuration file that defines rules for verifying container image signatures. It specifies:
- Which registries and repositories require signature verification
- What level of verification is required
- Which certificate authorities and identities are trusted
- How to handle verification failures

Trust policies are essential for implementing supply chain security by ensuring only signed and verified container images are deployed in your environment.

## Trust Policy Structure

A trust policy configuration follows this general structure:

```json
{
    "version": "1.0",
    "trustPolicies": [
        {
            "name": "policy-name",
            "registryScopes": ["registry-pattern"],
            "signatureVerification": {
                "level": "verification-level"
            },
            "trustStores": ["trust-store-references"],
            "trustedIdentities": ["identity-patterns"]
        }
    ]
}
```

## Configuration Settings Explained

### Version
- **Purpose**: Specifies the trust policy schema version
- **Values**: Currently `"1.0"`
- **Required**: Yes

### Trust Policies Array
Contains one or more trust policy objects, each defining verification rules for specific registry scopes.

#### Policy Name
- **Purpose**: Unique identifier for the policy
- **Type**: String
- **Required**: Yes
- **Example**: `"default"`, `"production"`, `"staging"`

#### Registry Scopes
- **Purpose**: Defines which container registries and repositories this policy applies to
- **Type**: Array of strings
- **Patterns**:
  - `"*"` - All registries and repositories
  - `"registry.example.com/*"` - All repositories in a specific registry
  - `"registry.example.com/namespace/*"` - All repositories in a namespace
  - `"registry.example.com/namespace/repo"` - Specific repository
- **Required**: Yes

#### Signature Verification Level
Defines how strictly signatures are verified:

- **`"strict"`**: All images must have valid signatures from trusted identities
- **`"permissive"`**: Signed images must have valid signatures, unsigned images are allowed
- **`"audit"`**: All images are allowed, but signature verification results are logged
- **`"skip"`**: No signature verification is performed

#### Trust Stores
- **Purpose**: References to certificate stores containing trusted root certificates
- **Type**: Array of strings
- **Format**: `"store-type:store-name"`
- **Common Types**:
  - `"ca:store-name"` - Certificate Authority store
  - `"signingAuthority:store-name"` - Signing authority certificates
  - `"tsa:store-name"` - Timestamp authority certificates

#### Trusted Identities
- **Purpose**: Defines which signing identities are trusted
- **Type**: Array of strings
- **Formats**:
  - `"x509.subject: Distinguished-Name"` - X.509 certificate subject
  - `"x509.sans: Subject-Alternative-Name"` - X.509 SAN field
  - `"*"` - Any identity (not recommended for production)

## Analysis of demo-trustpolicy.json

Let's break down your specific trust policy configuration:

```json
{
    "version": "1.0",
    "trustPolicies": [
        {
            "name": "default",
            "registryScopes": [
                "*"
            ],
            "signatureVerification": {
                "level": "strict"
            },
            "trustStores": [
                "ca:ca-certs"
            ],
            "trustedIdentities": [
                "x509.subject: C=US, ST=IL, L=Chicago, O=demo.io, OU=Demo, CN=Demo"
            ]
        }
    ]
}
```

### Your Configuration Breakdown:

#### 🔧 **Policy Name: "default"**
- This is a general-purpose policy that serves as the default verification rule
- Since it's named "default", it will likely be applied when no other specific policies match

#### 🌐 **Registry Scopes: ["*"]**
- **Scope**: Universal (applies to ALL container registries and repositories)
- **Impact**: Every container image pull will be subject to this trust policy
- **Security Level**: High - no exceptions for any registry

#### 🔒 **Signature Verification Level: "strict"**
- **Behavior**: ALL container images MUST have valid signatures
- **Enforcement**: Unsigned images or images with invalid signatures will be REJECTED
- **Use Case**: Maximum security - suitable for production environments with zero-trust policies

#### 🏪 **Trust Stores: ["ca:ca-certs"]**
- **Store Type**: Certificate Authority store
- **Store Name**: "ca-certs"
- **Purpose**: Contains the root certificates used to validate the certificate chains of signed images
- **Location**: This references a local certificate store named "ca-certs"

#### ✅ **Trusted Identities**
Your policy trusts signatures from certificates with this exact subject:
```
C=US, ST=IL, L=Chicago, O=demo.io, OU=Demo, CN=Demo
```

**Identity Breakdown**:
- **Country (C)**: US (United States)
- **State/Province (ST)**: IL (Illinois)
- **Locality (L)**: Chicago
- **Organization (O)**: demo.io
- **Organizational Unit (OU)**: Demo
- **Common Name (CN)**: Demo

**Security Implications**:
- Only images signed with certificates containing this EXACT subject will be trusted
- Very restrictive - provides strong security but requires careful certificate management

## Best Practices

### 1. **Use Specific Registry Scopes**
Instead of `"*"`, consider scoping to specific registries:
```json
"registryScopes": [
    "registry.company.com/*",
    "docker.io/company-namespace/*"
]
```

### 2. **Implement Graduated Policies**
Use different policies for different environments:
```json
"trustPolicies": [
    {
        "name": "production",
        "registryScopes": ["registry.company.com/prod/*"],
        "signatureVerification": {"level": "strict"}
    },
    {
        "name": "development",
        "registryScopes": ["registry.company.com/dev/*"],
        "signatureVerification": {"level": "permissive"}
    }
]
```

### 3. **Certificate Rotation Planning**
- Regularly update trusted identities before certificate expiration
- Maintain multiple valid identities during transition periods

### 4. **Monitoring and Alerting**
- Log all verification attempts and failures
- Set up alerts for signature verification failures
- Monitor for unexpected unsigned image pulls

## Common Use Cases

### Enterprise Environment
- **Level**: `"strict"`
- **Scope**: Company-specific registries
- **Identities**: Corporate signing certificates

### Development Environment
- **Level**: `"permissive"` or `"audit"`
- **Scope**: Development registries
- **Identities**: Broader set of trusted signers

### Public Registry Access
- **Level**: `"audit"`
- **Scope**: Public registries like Docker Hub
- **Identities**: Well-known public signers

## Security Considerations

Your current configuration provides **maximum security** with:
- ✅ Universal scope (all registries)
- ✅ Strict verification (no unsigned images)
- ✅ Single trusted identity (minimal attack surface)
- ✅ Defined certificate authority trust store

**Potential Considerations**:
- Ensure the "ca-certs" trust store is properly configured and accessible
- Have a certificate rotation strategy in place
- Consider adding backup trusted identities for business continuity
- Test the policy thoroughly before production deployment

## Troubleshooting

If you encounter signature verification failures, check:

1. **Certificate Validity**: Ensure the signing certificate hasn't expired
2. **Trust Store**: Verify the "ca-certs" store contains the correct root certificates
3. **Identity Match**: Confirm the certificate subject exactly matches your trusted identity
4. **Network Access**: Ensure the verification system can access necessary certificate validation services

---

*This README provides comprehensive documentation for your trust policy configuration. Update this document whenever you modify the trust policy settings.*
