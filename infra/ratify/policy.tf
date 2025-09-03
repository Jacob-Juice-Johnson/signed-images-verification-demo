resource "azurerm_policy_definition" "ratify_custom_policy" {
  name         = var.policy_definition_name
  policy_type  = "Custom"
  mode         = local.policy_definition.mode
  display_name = "Ratify Default Custom Policy"
  description  = "Custom Azure Policy for Ratify to verify signed container images"

  parameters  = jsonencode(local.policy_definition.parameters)
  policy_rule = jsonencode(local.policy_definition.policyRule)
}

resource "azurerm_resource_policy_assignment" "ratify_policy_assignment" {
  name                 = var.policy_definition_name
  resource_id          = data.azurerm_kubernetes_cluster.aks.id
  policy_definition_id = azurerm_policy_definition.ratify_custom_policy.id
  display_name         = "Ratify Policy Assignment"
  description          = "Assignment of Ratify custom policy to AKS cluster"

  parameters = jsonencode({
    effect = {
      value = var.policy_effect
    }
    excludedNamespaces = {
      value = var.excluded_namespaces
    }
    namespaces = {
      value = var.namespaces
    }
    labelSelector = {
      value = var.label_selector
    }
  })

  depends_on = [
    kubernetes_manifest.ratify_store_oras,
    kubernetes_manifest.ratify_kmp_akv,
    kubernetes_manifest.ratify_verifier_notation
  ]
}