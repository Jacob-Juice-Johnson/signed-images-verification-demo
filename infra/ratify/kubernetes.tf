resource "kubernetes_manifest" "ratify_store_oras" {
  manifest = {
    apiVersion = "config.ratify.deislabs.io/v1beta1"
    kind       = "Store"
    metadata = {
      name      = "store-oras"
    }
    spec = {
      name = "oras"
      parameters = {
        authProvider = {
          name     = "azureWorkloadIdentity"
          clientID = data.azurerm_user_assigned_identity.ratify_identity.client_id
        }
        cosignEnabled = true
      }
    }
  }
}

resource "kubernetes_manifest" "ratify_kmp_akv" {
  manifest = {
    apiVersion = "config.ratify.deislabs.io/v1beta1"
    kind       = "KeyManagementProvider"
    metadata = {
      name      = "keymanagementprovider-akv"
    }
    spec = {
      type = "azurekeyvault"
      parameters = {
        vaultURI = "https://${var.key_vault_name}.vault.azure.net/"
        certificates = [
          {
            name    = var.certificate_name
            version = data.azurerm_key_vault_certificate.ratify_cert.version
          }
        ]
        tenantID = data.azurerm_client_config.current.tenant_id
        clientID = data.azurerm_user_assigned_identity.ratify_identity.client_id
      }
    }
  }
}

resource "kubernetes_manifest" "ratify_verifier_notation" {
  manifest = {
    apiVersion = "config.ratify.deislabs.io/v1beta1"
    kind       = "Verifier"
    metadata = {
      name      = "verifier-notation"
    }
    spec = {
      name          = "notation"
      artifactTypes = "application/vnd.cncf.notary.signature"
      parameters = {
        verificationCertStores = {
          ca = {
            "ca-certs" = [
              "keymanagementprovider-akv"
            ]
          }
        }
        trustPolicyDoc = {
          version = "1.0"
          trustPolicies = [
            {
              name = "default"
              registryScopes = [
                "*"
              ]
              signatureVerification = {
                level = "strict"
              }
              trustStores = [
                "ca:ca-certs"
              ]
              trustedIdentities = [
                "x509.subject: ${var.certificate_subject_dn}"
              ]
            }
          ]
        }
      }
    }
  }
  depends_on = [
    kubernetes_manifest.ratify_kmp_akv
  ]
}

