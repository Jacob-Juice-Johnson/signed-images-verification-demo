# Service Principal outputs for GitHub Actions
output "github_actions_client_id" {
  description = "Client ID for GitHub Actions service principal"
  value       = azuread_application.github_actions.client_id
}

output "github_actions_client_secret" {
  description = "Client Secret for GitHub Actions service principal"
  value       = azuread_service_principal_password.github_actions.value
  sensitive   = true
}

output "github_actions_tenant_id" {
  description = "Tenant ID for GitHub Actions"
  value       = data.azurerm_client_config.current.tenant_id
}

output "github_actions_subscription_id" {
  description = "Subscription ID for GitHub Actions"
  value       = data.azurerm_client_config.current.subscription_id
}

# Convenience output for GitHub Actions secrets
output "github_actions_azure_credentials" {
  description = "JSON formatted credentials for GitHub Actions AZURE_CREDENTIALS secret"
  value = jsonencode({
    clientId       = azuread_application.github_actions.client_id
    clientSecret   = azuread_service_principal_password.github_actions.value
    subscriptionId = data.azurerm_client_config.current.subscription_id
    tenantId       = data.azurerm_client_config.current.tenant_id
  })
  sensitive = true
}
