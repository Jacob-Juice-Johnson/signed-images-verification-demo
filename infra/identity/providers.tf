terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "abaecb33-47b5-451a-abce-59549340ac7b"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
