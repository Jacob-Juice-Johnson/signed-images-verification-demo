data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "ratify_identity" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

data "azurerm_key_vault_certificate" "ratify_cert" {
  name         = var.certificate_name
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}