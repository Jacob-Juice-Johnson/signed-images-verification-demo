output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = data.azurerm_kubernetes_cluster.aks.id
}

output "ratify_store_name" {
  description = "The name of the Ratify store resource"
  value       = kubernetes_manifest.ratify_store_oras.manifest.metadata.name
}

output "ratify_namespace" {
  description = "The namespace where Ratify resources are deployed"
  value       = var.ratify_namespace
}

output "identity_client_id" {
  description = "The client ID of the Azure User Assigned Identity"
  value       = data.azurerm_user_assigned_identity.ratify_identity.client_id
}

output "identity_principal_id" {
  description = "The principal ID of the Azure User Assigned Identity"
  value       = data.azurerm_user_assigned_identity.ratify_identity.principal_id
}

output "ratify_kmp_name" {
  description = "The name of the Ratify KeyManagementProvider resource"
  value       = kubernetes_manifest.ratify_kmp_akv.manifest.metadata.name
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault"
  value       = "https://${var.key_vault_name}.vault.azure.net/"
}

output "tenant_id" {
  description = "The Azure tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "certificate_version" {
  description = "The version of the Key Vault certificate being used"
  value       = data.azurerm_key_vault_certificate.ratify_cert.version
}

output "key_vault_id" {
  description = "The ID of the Azure Key Vault"
  value       = data.azurerm_key_vault.kv.id
}

output "notation_verifier_name" {
  description = "The name of the Notation verifier resource"
  value       = kubernetes_manifest.ratify_verifier_notation.manifest.metadata.name
}
