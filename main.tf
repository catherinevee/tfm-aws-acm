# ==============================================================================
# Azure Certificate Management Module (AWS ACM Equivalent)
# ==============================================================================
# This module provides certificate management functionality similar to AWS ACM
# using Azure Key Vault for certificate storage and management.
# ==============================================================================

# ==============================================================================
# Azure Key Vault
# ==============================================================================
# The Key Vault serves as the primary certificate store, similar to AWS ACM
# ==============================================================================

resource "azurerm_key_vault" "certificate_vault" {
  name                        = var.key_vault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = var.enabled_for_disk_encryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.soft_delete_retention_days
  purge_protection_enabled    = var.purge_protection_enabled
  sku_name                    = var.key_vault_sku_name

  # Network access configuration
  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }

  # Access policies for the current user/service principal
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    certificate_permissions = var.certificate_permissions
    key_permissions         = var.key_permissions
    secret_permissions      = var.secret_permissions
    storage_permissions     = var.storage_permissions
  }

  # Additional access policies
  dynamic "access_policy" {
    for_each = var.additional_access_policies
    content {
      tenant_id = access_policy.value.tenant_id
      object_id = access_policy.value.object_id

      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  # Tags
  tags = merge(var.tags, {
    Module = "azure-certificate-management"
    Purpose = "Certificate Storage"
  })
}

# ==============================================================================
# Self-Signed Certificates
# ==============================================================================
# Create self-signed certificates for development/testing purposes
# ==============================================================================

resource "azurerm_key_vault_certificate" "self_signed" {
  for_each = var.self_signed_certificates

  name         = each.key
  key_vault_id = azurerm_key_vault.certificate_vault.id

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = each.value.exportable
      key_size   = each.value.key_size
      key_type   = each.value.key_type
      reuse_key  = each.value.reuse_key
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = each.value.days_before_expiry
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      extended_key_usage = each.value.extended_key_usage
      key_usage          = each.value.key_usage
      subject_alternative_names {
        dns_names = each.value.dns_names
        emails    = each.value.emails
        upns      = each.value.upns
      }
      subject            = each.value.subject
      validity_in_months = each.value.validity_in_months
    }
  }

  tags = merge(var.tags, {
    CertificateType = "SelfSigned"
    Domain          = join(",", each.value.dns_names)
  })
}

# ==============================================================================
# Imported Certificates
# ==============================================================================
# Import existing certificates from files or other sources
# ==============================================================================

resource "azurerm_key_vault_certificate" "imported" {
  for_each = var.imported_certificates

  name         = each.key
  key_vault_id = azurerm_key_vault.certificate_vault.id

  certificate {
    contents = base64encode(file(each.value.certificate_file))
    password = each.value.certificate_password
  }

  tags = merge(var.tags, {
    CertificateType = "Imported"
    Source          = each.value.certificate_file
  })
}

# ==============================================================================
# Certificate Issuers
# ==============================================================================
# Configure certificate authorities for automatic certificate issuance
# ==============================================================================

resource "azurerm_key_vault_certificate_issuer" "ca_issuers" {
  for_each = var.certificate_issuers

  name            = each.key
  key_vault_id    = azurerm_key_vault.certificate_vault.id
  provider_name   = each.value.provider_name

  account_id = each.value.account_id
  password   = each.value.password

  dynamic "admin" {
    for_each = each.value.admin_contacts
    content {
      first_name = admin.value.first_name
      last_name  = admin.value.last_name
      email_address = admin.value.email_address
      phone      = admin.value.phone
    }
  }

  dynamic "org_id" {
    for_each = each.value.organization_id != null ? [each.value.organization_id] : []
    content {
      id = org_id.value
    }
  }
}

# ==============================================================================
# Certificate Contacts
# ==============================================================================
# Configure certificate contacts for notifications
# ==============================================================================

resource "azurerm_key_vault_certificate_contacts" "contacts" {
  count = length(var.certificate_contacts) > 0 ? 1 : 0

  key_vault_id = azurerm_key_vault.certificate_vault.id

  dynamic "contact" {
    for_each = var.certificate_contacts
    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }
}

# ==============================================================================
# Certificate Secrets
# ==============================================================================
# Store certificate secrets for applications that need them
# ==============================================================================

resource "azurerm_key_vault_secret" "certificate_secrets" {
  for_each = var.certificate_secrets

  name         = each.key
  value        = each.value.secret_value
  key_vault_id = azurerm_key_vault.certificate_vault.id

  content_type = each.value.content_type
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  tags = merge(var.tags, {
    SecretType = "Certificate"
    Purpose    = each.value.purpose
  })
}

# ==============================================================================
# Data Sources
# ==============================================================================
# Get current Azure client configuration
# ==============================================================================

data "azurerm_client_config" "current" {}

# ==============================================================================
# Private Link Endpoint (Optional)
# ==============================================================================
# Create private endpoint for secure access to Key Vault
# ==============================================================================

resource "azurerm_private_endpoint" "key_vault_pe" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.certificate_vault.id
    is_manual_connection           = false
    subresource_names             = ["vault"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = merge(var.tags, {
    Purpose = "PrivateEndpoint"
  })
}

# ==============================================================================
# Diagnostic Settings
# ==============================================================================
# Configure diagnostic settings for monitoring and logging
# ==============================================================================

resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostics" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${var.key_vault_name}-diagnostics"
  target_resource_id         = azurerm_key_vault.certificate_vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id

  dynamic "log" {
    for_each = var.diagnostic_log_categories
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = true
        days    = var.diagnostic_retention_days
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = var.diagnostic_retention_days
    }
  }
} 