variable "registry_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "identity_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ratify_namespace" {
  type    = string
  default = "gatekeeper-system"
}

variable "ratify_cert_name" {
  type    = string
  default = "ratify"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "VM size for AKS nodes - B2s is cost-effective for demos"
}