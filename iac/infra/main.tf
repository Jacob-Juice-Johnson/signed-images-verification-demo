resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "registry" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
}

resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  rbac_authorization_enabled  = true
  tags                        = var.tags

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azuread_client_config.current.object_id

    key_permissions = [
      "Get", "Sign", "List"
    ]

    secret_permissions = [
      "Get", "Set", "List", "Delete", "Purge"
    ]

    certificate_permissions = [
      "Get", "Create", "Delete", "Purge", "List"
    ]
  }
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                      = var.cluster_name
  location                  = azurerm_resource_group.rg.location
  resource_group_name       = azurerm_resource_group.rg.name
  dns_prefix                = "${var.cluster_name}-dns"
  kubernetes_version        = "1.30.6"
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = var.vm_size
  }

  web_app_routing {
    dns_zone_ids = []
  }

  azure_policy_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings
    ]
  }
}

resource "azurerm_key_vault_certificate" "ratify-cert" {
  name         = var.ratify_cert_name
  key_vault_id = azurerm_key_vault.kv.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = ["1.3.6.1.5.5.7.3.3"]

      key_usage = [
        "digitalSignature",
      ]

      subject            = "CN=demo.com"
      validity_in_months = 12
    }
  }

  lifecycle {
    create_before_destroy = false
  }
}

# Install Ratify CRDs
resource "helm_release" "ratify" {
  name             = "ratify"
  repository       = "https://notaryproject.github.io/ratify"
  chart            = "ratify"
  namespace        = "gatekeeper-system"
  atomic           = true

  set {
    name  = "provider.enableMutation"
    value = "false"
  }

  set {
    name  = "featureFlags.RATIFY_CERT_ROTATION"
    value = "true"
  }

  set {
    name  = "azureWorkloadIdentity.clientId"
    value = azurerm_user_assigned_identity.identity.client_id
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks,
    azurerm_federated_identity_credential.workload-identity-credential,
    azurerm_role_assignment.key_vault_secrets_user
  ]
}
