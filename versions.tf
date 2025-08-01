# ==============================================================================
# Terraform and Provider Versions
# ==============================================================================
# This file specifies the required Terraform and provider versions
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

# ==============================================================================
# Provider Configuration
# ==============================================================================
# Azure provider configuration with default settings
# ==============================================================================

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
} 