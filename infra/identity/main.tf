# Service Principal for GitHub Actions
resource "azuread_application" "github_actions" {
  display_name = "GitHub Actions - ${var.spn_name}"
  description  = "Service principal for GitHub Actions workflows"
}

resource "azuread_service_principal" "github_actions" {
  client_id = azuread_application.github_actions.client_id
}

resource "azuread_service_principal_password" "github_actions" {
  service_principal_id = azuread_service_principal.github_actions.id
  display_name         = "GitHub Actions Password"
  end_date            = timeadd(timestamp(), "24h")  # Expires in 24 hours
}

# Role assignments for the service principal
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

resource "azurerm_role_assignment" "github_actions_key_vault_admin" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# User role assignment (existing)
resource "azurerm_role_assignment" "user_key_vault_admin" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azuread_client_config.current.object_id
}