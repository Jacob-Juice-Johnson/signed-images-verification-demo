variable "resource_group_name" {
  description = "The name of the resource group where the AKS cluster and identity exist"
  type        = string
}

variable "aks_cluster_name" {
  description = "The name of the existing AKS cluster"
  type        = string
}

variable "policy_definition_name" {
  description = "Name for the policy definition"
  type        = string
  default     = "ratify-image-signing-verification"
}

variable "identity_name" {
  description = "The name of the Azure User Assigned Identity for Ratify authentication"
  type        = string
}

variable "ratify_namespace" {
  description = "The Kubernetes namespace where Ratify resources will be deployed"
  type        = string
  default     = "gatekeeper-system"
}

variable "key_vault_name" {
  description = "The name of the Azure Key Vault containing certificates"
  type        = string
}

variable "certificate_name" {
  description = "The name of the certificate in Azure Key Vault"
  type        = string
}

variable "certificate_subject_dn" {
  description = "The subject Distinguished Name (DN) of the certificate for trusted identities"
  type        = string
}