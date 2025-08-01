# ==============================================================================
# Basic Example - Azure Certificate Management Module
# ==============================================================================
# This example demonstrates the basic usage of the certificate management module
# with minimal configuration for development and testing purposes.
# ==============================================================================

# ==============================================================================
# Provider Configuration
# ==============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# ==============================================================================
# Resource Group
# ==============================================================================

resource "azurerm_resource_group" "example" {
  name     = "rg-certificate-management-example"
  location = "eastus"

  tags = {
    Environment = "Development"
    Project     = "Certificate Management Example"
  }
}

# ==============================================================================
# Certificate Management Module
# ==============================================================================

module "certificate_management" {
  source = "../../"

  # Required parameters
  key_vault_name      = "kv-cert-example-${random_string.suffix.result}"
  location           = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Key Vault Configuration
  soft_delete_retention_days = 7
  purge_protection_enabled   = false  # Disabled for development
  key_vault_sku_name         = "standard"

  # Create a self-signed certificate for development
  self_signed_certificates = {
    "web-app-dev" = {
      dns_names = ["localhost", "127.0.0.1"]
      subject   = "CN=localhost"
      key_size  = 2048
      validity_in_months = 12
      days_before_expiry = 30
      exportable = true
      reuse_key  = true
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
      key_usage = ["digitalSignature", "keyEncipherment"]
    }
  }

  # Certificate contacts for notifications
  certificate_contacts = [
    {
      email = "admin@example.com"
      name  = "Development Administrator"
    }
  ]

  # Tags
  tags = {
    Environment = "Development"
    Project     = "Certificate Management Example"
    Purpose     = "Development and Testing"
  }
}

# ==============================================================================
# Random String for Unique Naming
# ==============================================================================

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ==============================================================================
# Outputs
# ==============================================================================

output "key_vault_id" {
  description = "The ID of the created Key Vault"
  value       = module.certificate_management.key_vault_id
}

output "key_vault_uri" {
  description = "The URI of the created Key Vault"
  value       = module.certificate_management.key_vault_uri
}

output "certificates" {
  description = "Details of created certificates"
  value       = module.certificate_management.self_signed_certificates
}

output "summary" {
  description = "Summary of the deployment"
  value       = module.certificate_management.summary
} 