# ==============================================================================
# Local Values for Azure Certificate Management Module
# ==============================================================================
# This file defines local values and computed attributes used throughout the module
# ==============================================================================

# ==============================================================================
# Common Tags
# ==============================================================================

locals {
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Module    = "azure-certificate-management"
    Version   = "1.0.0"
    ManagedBy = "Terraform"
  })

  # Key Vault specific tags
  key_vault_tags = merge(local.common_tags, {
    Purpose = "Certificate Storage"
    Service = "Key Vault"
  })

  # Certificate specific tags
  certificate_tags = merge(local.common_tags, {
    Purpose = "Certificate Management"
    Service = "Certificates"
  })

  # Private endpoint tags
  private_endpoint_tags = merge(local.common_tags, {
    Purpose = "Private Endpoint"
    Service = "Networking"
  })

  # Diagnostic settings tags
  diagnostic_tags = merge(local.common_tags, {
    Purpose = "Monitoring"
    Service = "Diagnostics"
  })
}

# ==============================================================================
# Naming Conventions
# ==============================================================================

locals {
  # Resource naming patterns
  name_patterns = {
    key_vault = "kv-${var.key_vault_name}"
    private_endpoint = "${var.key_vault_name}-pe"
    diagnostic_settings = "${var.key_vault_name}-diagnostics"
  }

  # Validation patterns
  validation_patterns = {
    key_vault_name = "^[a-zA-Z0-9-]{3,24}$"
    location = "^[a-z0-9-]+$"
  }
}

# ==============================================================================
# Computed Values
# ==============================================================================

locals {
  # Determine if private endpoint is enabled
  enable_private_endpoint = var.enable_private_endpoint && var.private_endpoint_subnet_id != null

  # Determine if diagnostic settings are enabled
  enable_diagnostic_settings = var.enable_diagnostic_settings && (
    var.log_analytics_workspace_id != null || var.storage_account_id != null
  )

  # Determine if network ACLs are configured
  has_network_acls = var.network_acls != null

  # Determine if additional access policies are configured
  has_additional_access_policies = length(var.additional_access_policies) > 0

  # Determine if certificate contacts are configured
  has_certificate_contacts = length(var.certificate_contacts) > 0

  # Determine if certificate issuers are configured
  has_certificate_issuers = length(var.certificate_issuers) > 0

  # Determine if certificate secrets are configured
  has_certificate_secrets = length(var.certificate_secrets) > 0

  # Determine if self-signed certificates are configured
  has_self_signed_certificates = length(var.self_signed_certificates) > 0

  # Determine if imported certificates are configured
  has_imported_certificates = length(var.imported_certificates) > 0
}

# ==============================================================================
# Security Configuration
# ==============================================================================

locals {
  # Default security settings
  security_defaults = {
    # Minimum key size for certificates
    min_key_size = 2048
    
    # Maximum key size for certificates
    max_key_size = 4096
    
    # Minimum validity period in months
    min_validity_months = 1
    
    # Maximum validity period in months
    max_validity_months = 60
    
    # Minimum days before expiry for renewal
    min_days_before_expiry = 7
    
    # Maximum days before expiry for renewal
    max_days_before_expiry = 90
    
    # Minimum soft delete retention days
    min_soft_delete_days = 7
    
    # Maximum soft delete retention days
    max_soft_delete_days = 90
    
    # Minimum diagnostic retention days
    min_diagnostic_retention_days = 1
    
    # Maximum diagnostic retention days
    max_diagnostic_retention_days = 365
  }

  # Production security settings
  production_security = {
    # Require premium SKU for production
    require_premium_sku = var.key_vault_sku_name == "premium"
    
    # Require purge protection for production
    require_purge_protection = var.purge_protection_enabled
    
    # Require network ACLs for production
    require_network_acls = local.has_network_acls
    
    # Require private endpoint for production
    require_private_endpoint = local.enable_private_endpoint
    
    # Require diagnostic settings for production
    require_diagnostic_settings = local.enable_diagnostic_settings
  }
}

# ==============================================================================
# Certificate Configuration
# ==============================================================================

locals {
  # Default certificate settings
  certificate_defaults = {
    # Default key size
    default_key_size = 2048
    
    # Default key type
    default_key_type = "RSA"
    
    # Default validity period in months
    default_validity_months = 12
    
    # Default days before expiry
    default_days_before_expiry = 30
    
    # Default extended key usage
    default_extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
    
    # Default key usage
    default_key_usage = ["digitalSignature", "keyEncipherment"]
    
    # Default content type for secrets
    default_secret_content_type = "application/x-pkcs12"
    
    # Default exportable setting
    default_exportable = true
    
    # Default reuse key setting
    default_reuse_key = true
  }

  # Certificate validation rules
  certificate_validation = {
    # Validate key size
    valid_key_sizes = [2048, 3072, 4096]
    
    # Validate key types
    valid_key_types = ["RSA", "EC"]
    
    # Validate extended key usage OIDs
    valid_extended_key_usage = [
      "1.3.6.1.5.5.7.3.1",  # Server Authentication
      "1.3.6.1.5.5.7.3.2",  # Client Authentication
      "1.3.6.1.5.5.7.3.3",  # Code Signing
      "1.3.6.1.5.5.7.3.4",  # Email Protection
      "1.3.6.1.5.5.7.3.8"   # Time Stamping
    ]
    
    # Validate key usage
    valid_key_usage = [
      "digitalSignature",
      "nonRepudiation",
      "keyEncipherment",
      "dataEncipherment",
      "keyAgreement",
      "keyCertSign",
      "cRLSign",
      "encipherOnly",
      "decipherOnly"
    ]
  }
}

# ==============================================================================
# Network Configuration
# ==============================================================================

locals {
  # Network ACL validation
  network_acl_validation = {
    # Valid default actions
    valid_default_actions = ["Allow", "Deny"]
    
    # Valid bypass options
    valid_bypass_options = ["AzureServices", "None"]
    
    # Required fields for network ACLs
    required_fields = ["default_action", "bypass"]
  }

  # Private endpoint configuration
  private_endpoint_config = {
    # Private DNS zone for Key Vault
    key_vault_dns_zone = "privatelink.vaultcore.azure.net"
    
    # Subresource name for Key Vault
    key_vault_subresource = "vault"
    
    # Private endpoint group name
    endpoint_group_name = "default"
  }
}

# ==============================================================================
# Monitoring Configuration
# ==============================================================================

locals {
  # Diagnostic log categories
  diagnostic_categories = {
    # Key Vault audit logs
    audit_event = "AuditEvent"
    
    # Azure Policy evaluation details
    azure_policy = "AzurePolicyEvaluationDetails"
  }

  # Metric categories
  metric_categories = {
    # All metrics
    all_metrics = "AllMetrics"
  }

  # Default diagnostic settings
  diagnostic_defaults = {
    # Default retention days
    default_retention_days = 30
    
    # Default log categories
    default_log_categories = [
      local.diagnostic_categories.audit_event,
      local.diagnostic_categories.azure_policy
    ]
    
    # Default metric category
    default_metric_category = local.metric_categories.all_metrics
  }
} 