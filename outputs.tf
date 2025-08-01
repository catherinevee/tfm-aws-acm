# ==============================================================================
# Outputs for Azure Certificate Management Module
# ==============================================================================
# This file defines all output values that can be used by other modules
# ==============================================================================

# ==============================================================================
# Key Vault Outputs
# ==============================================================================

output "key_vault_id" {
  description = "The ID of the Azure Key Vault"
  value       = azurerm_key_vault.certificate_vault.id
}

output "key_vault_name" {
  description = "The name of the Azure Key Vault"
  value       = azurerm_key_vault.certificate_vault.name
}

output "key_vault_uri" {
  description = "The URI of the Azure Key Vault"
  value       = azurerm_key_vault.certificate_vault.vault_uri
}

output "key_vault_resource_id" {
  description = "The resource ID of the Azure Key Vault"
  value       = azurerm_key_vault.certificate_vault.resource_id
}

# ==============================================================================
# Certificate Outputs
# ==============================================================================

output "self_signed_certificates" {
  description = "Map of created self-signed certificates"
  value = {
    for name, cert in azurerm_key_vault_certificate.self_signed : name => {
      id           = cert.id
      name         = cert.name
      version      = cert.version
      thumbprint   = cert.thumbprint
      certificate_data = cert.certificate_data
      certificate_data_base64 = cert.certificate_data_base64
    }
  }
}

output "imported_certificates" {
  description = "Map of imported certificates"
  value = {
    for name, cert in azurerm_key_vault_certificate.imported : name => {
      id           = cert.id
      name         = cert.name
      version      = cert.version
      thumbprint   = cert.thumbprint
      certificate_data = cert.certificate_data
      certificate_data_base64 = cert.certificate_data_base64
    }
  }
}

output "all_certificates" {
  description = "Combined map of all certificates (self-signed and imported)"
  value = merge(
    {
      for name, cert in azurerm_key_vault_certificate.self_signed : "self-signed-${name}" => {
        id           = cert.id
        name         = cert.name
        version      = cert.version
        thumbprint   = cert.thumbprint
        type         = "self-signed"
        certificate_data = cert.certificate_data
        certificate_data_base64 = cert.certificate_data_base64
      }
    },
    {
      for name, cert in azurerm_key_vault_certificate.imported : "imported-${name}" => {
        id           = cert.id
        name         = cert.name
        version      = cert.version
        thumbprint   = cert.thumbprint
        type         = "imported"
        certificate_data = cert.certificate_data
        certificate_data_base64 = cert.certificate_data_base64
      }
    }
  )
}

# ==============================================================================
# Certificate Issuer Outputs
# ==============================================================================

output "certificate_issuers" {
  description = "Map of configured certificate issuers"
  value = {
    for name, issuer in azurerm_key_vault_certificate_issuer.ca_issuers : name => {
      id           = issuer.id
      name         = issuer.name
      provider_name = issuer.provider_name
      account_id   = issuer.account_id
    }
  }
}

# ==============================================================================
# Certificate Contacts Outputs
# ==============================================================================

output "certificate_contacts" {
  description = "Certificate contacts configuration"
  value = length(azurerm_key_vault_certificate_contacts.contacts) > 0 ? {
    id = azurerm_key_vault_certificate_contacts.contacts[0].id
    contacts = azurerm_key_vault_certificate_contacts.contacts[0].contact
  } : null
}

# ==============================================================================
# Certificate Secrets Outputs
# ==============================================================================

output "certificate_secrets" {
  description = "Map of certificate secrets"
  value = {
    for name, secret in azurerm_key_vault_secret.certificate_secrets : name => {
      id           = secret.id
      name         = secret.name
      version      = secret.version
      content_type = secret.content_type
      not_before_date = secret.not_before_date
      expiration_date = secret.expiration_date
    }
  }
}

# ==============================================================================
# Private Endpoint Outputs
# ==============================================================================

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.key_vault_pe[0].id : null
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.key_vault_pe[0].private_service_connection[0].private_ip_address : null
}

# ==============================================================================
# Diagnostic Settings Outputs
# ==============================================================================

output "diagnostic_settings_id" {
  description = "The ID of the diagnostic settings (if enabled)"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.key_vault_diagnostics[0].id : null
}

# ==============================================================================
# Access Policy Outputs
# ==============================================================================

output "access_policies" {
  description = "Current access policies on the Key Vault"
  value = {
    current_user = {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id
      certificate_permissions = var.certificate_permissions
      key_permissions         = var.key_permissions
      secret_permissions      = var.secret_permissions
      storage_permissions     = var.storage_permissions
    }
    additional_policies = var.additional_access_policies
  }
}

# ==============================================================================
# Network Configuration Outputs
# ==============================================================================

output "network_acls" {
  description = "Network access control configuration"
  value = var.network_acls != null ? {
    default_action             = var.network_acls.default_action
    bypass                     = var.network_acls.bypass
    ip_rules                   = var.network_acls.ip_rules
    virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
  } : null
}

# ==============================================================================
# Summary Outputs
# ==============================================================================

output "summary" {
  description = "Summary of the certificate management module deployment"
  value = {
    key_vault = {
      id   = azurerm_key_vault.certificate_vault.id
      name = azurerm_key_vault.certificate_vault.name
      uri  = azurerm_key_vault.certificate_vault.vault_uri
    }
    certificates = {
      self_signed_count = length(azurerm_key_vault_certificate.self_signed)
      imported_count    = length(azurerm_key_vault_certificate.imported)
      total_count       = length(azurerm_key_vault_certificate.self_signed) + length(azurerm_key_vault_certificate.imported)
    }
    issuers = {
      count = length(azurerm_key_vault_certificate_issuer.ca_issuers)
    }
    secrets = {
      count = length(azurerm_key_vault_secret.certificate_secrets)
    }
    features = {
      private_endpoint_enabled = var.enable_private_endpoint
      diagnostics_enabled      = var.enable_diagnostic_settings
      purge_protection         = var.purge_protection_enabled
      soft_delete_days         = var.soft_delete_retention_days
    }
  }
} 