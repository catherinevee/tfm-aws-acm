# ==============================================================================
# Advanced Example - Azure Certificate Management Module
# ==============================================================================
# This example demonstrates advanced usage of the certificate management module
# with comprehensive configuration including networking, monitoring, and security.
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
    random = {
      source  = "hashicorp/random"
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
  name     = "rg-certificate-management-advanced"
  location = "eastus"

  tags = {
    Environment = "Production"
    Project     = "Advanced Certificate Management"
  }
}

# ==============================================================================
# Virtual Network and Subnets
# ==============================================================================

resource "azurerm_virtual_network" "example" {
  name                = "vnet-cert-example"
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  address_space      = ["10.0.0.0/16"]

  tags = {
    Environment = "Production"
    Purpose     = "Certificate Management Network"
  }
}

resource "azurerm_subnet" "private" {
  name                 = "snet-private"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "public" {
  name                 = "snet-public"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# ==============================================================================
# Log Analytics Workspace
# ==============================================================================

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-cert-example-${random_string.suffix.result}"
  location           = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                = "PerGB2018"
  retention_in_days  = 30

  tags = {
    Environment = "Production"
    Purpose     = "Certificate Management Monitoring"
  }
}

# ==============================================================================
# Storage Account for Diagnostics
# ==============================================================================

resource "azurerm_storage_account" "example" {
  name                     = "stcert${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
  min_tls_version         = "TLS1_2"

  tags = {
    Environment = "Production"
    Purpose     = "Certificate Management Diagnostics"
  }
}

# ==============================================================================
# Private DNS Zone
# ==============================================================================

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "Production"
    Purpose     = "Key Vault Private DNS"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "key-vault-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = azurerm_virtual_network.example.id

  tags = {
    Environment = "Production"
  }
}

# ==============================================================================
# Certificate Management Module
# ==============================================================================

module "certificate_management" {
  source = "../../"

  # Required parameters
  key_vault_name      = "kv-cert-advanced-${random_string.suffix.result}"
  location           = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Key Vault Configuration
  soft_delete_retention_days = 30
  purge_protection_enabled   = true
  key_vault_sku_name         = "premium"
  enabled_for_disk_encryption = true

  # Network Access Control
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["10.0.0.0/8", "192.168.0.0/16"]
    virtual_network_subnet_ids = [azurerm_subnet.private.id]
  }

  # Access Policies - More restrictive for production
  certificate_permissions = ["Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"]
  key_permissions         = ["Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover"]
  secret_permissions      = ["Get", "List", "Set", "Delete", "Backup", "Restore", "Recover"]
  storage_permissions     = ["Get", "List", "Delete", "Set", "Update", "RegenerateKey", "Recover", "Backup", "Restore"]

  # Additional access policies for other services
  additional_access_policies = [
    {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = "00000000-0000-0000-0000-000000000000"  # Replace with actual service principal ID
      certificate_permissions = ["Get", "List"]
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List"]
      storage_permissions     = ["Get", "List"]
    }
  ]

  # Self-Signed Certificates
  self_signed_certificates = {
    "api-production" = {
      dns_names = ["api.example.com", "api.prod.example.com"]
      subject   = "CN=api.example.com"
      key_size  = 4096
      validity_in_months = 24
      days_before_expiry = 60
      exportable = true
      reuse_key  = true
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
      key_usage = ["digitalSignature", "keyEncipherment"]
    }
    "web-production" = {
      dns_names = ["www.example.com", "example.com"]
      subject   = "CN=www.example.com"
      key_size  = 2048
      validity_in_months = 12
      days_before_expiry = 30
      exportable = true
      reuse_key  = true
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
      key_usage = ["digitalSignature", "keyEncipherment"]
    }
    "wildcard-production" = {
      dns_names = ["*.example.com", "example.com"]
      subject   = "CN=*.example.com"
      key_size  = 2048
      validity_in_months = 12
      days_before_expiry = 30
      exportable = true
      reuse_key  = true
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
      key_usage = ["digitalSignature", "keyEncipherment"]
    }
  }

  # Imported Certificates (example - would need actual certificate files)
  imported_certificates = {
    # Uncomment and configure when you have certificate files
    # "legacy-cert" = {
    #   certificate_file     = "./certs/legacy-cert.pfx"
    #   certificate_password = "your-password"
    # }
  }

  # Certificate Issuers
  certificate_issuers = {
    "digicert" = {
      provider_name = "DigiCert"
      account_id    = "your-digicert-account-id"
      password      = "your-digicert-password"
      admin_contacts = [
        {
          first_name    = "John"
          last_name     = "Doe"
          email_address = "john.doe@example.com"
          phone         = "+1-555-0123"
        },
        {
          first_name    = "Jane"
          last_name     = "Smith"
          email_address = "jane.smith@example.com"
          phone         = "+1-555-0456"
        }
      ]
      organization_id = "your-organization-id"
    }
  }

  # Certificate Contacts
  certificate_contacts = [
    {
      email = "admin@example.com"
      name  = "System Administrator"
      phone = "+1-555-0123"
    },
    {
      email = "security@example.com"
      name  = "Security Team"
      phone = "+1-555-0456"
    }
  ]

  # Certificate Secrets
  certificate_secrets = {
    "api-key" = {
      secret_value = "your-api-key-here"
      content_type = "text/plain"
      purpose      = "API Authentication"
    }
    "database-password" = {
      secret_value = "your-database-password"
      content_type = "text/plain"
      purpose      = "Database Connection"
    }
  }

  # Private Endpoint Configuration
  enable_private_endpoint = true
  private_endpoint_subnet_id = azurerm_subnet.private.id
  private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]

  # Diagnostic Settings
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  storage_account_id         = azurerm_storage_account.example.id
  diagnostic_log_categories  = ["AuditEvent", "AzurePolicyEvaluationDetails"]
  diagnostic_retention_days  = 90

  # Tags
  tags = {
    Environment = "Production"
    Project     = "Advanced Certificate Management"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
    Compliance  = "SOC2"
  }
}

# ==============================================================================
# Data Sources
# ==============================================================================

data "azurerm_client_config" "current" {}

# ==============================================================================
# Random String for Unique Naming
# ==============================================================================

resource "random_string" "suffix" {
  length  = 8
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

output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = module.certificate_management.private_endpoint_id
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = module.certificate_management.private_endpoint_ip_address
}

output "certificates" {
  description = "Details of created certificates"
  value       = module.certificate_management.all_certificates
}

output "certificate_issuers" {
  description = "Details of configured certificate issuers"
  value       = module.certificate_management.certificate_issuers
}

output "certificate_contacts" {
  description = "Certificate contacts configuration"
  value       = module.certificate_management.certificate_contacts
}

output "certificate_secrets" {
  description = "Certificate secrets (sensitive)"
  value       = module.certificate_management.certificate_secrets
  sensitive   = true
}

output "diagnostic_settings_id" {
  description = "The ID of the diagnostic settings"
  value       = module.certificate_management.diagnostic_settings_id
}

output "summary" {
  description = "Summary of the deployment"
  value       = module.certificate_management.summary
}

output "network_configuration" {
  description = "Network configuration details"
  value = {
    virtual_network_id = azurerm_virtual_network.example.id
    private_subnet_id  = azurerm_subnet.private.id
    public_subnet_id   = azurerm_subnet.public.id
    private_dns_zone_id = azurerm_private_dns_zone.key_vault.id
  }
} 