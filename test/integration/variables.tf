variable "test_resource_group_name" {
  description = "Name of the resource group for testing"
  type        = string
  default     = "test-cert-mgmt-rg"
}

variable "test_location" {
  description = "Azure region for testing"
  type        = string
  default     = "eastus"
}

variable "test_key_vault_name" {
  description = "Name of the test Key Vault"
  type        = string
  default     = "test-cert-vault"
}
