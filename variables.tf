# ==============================================================================
# Variables for Azure Certificate Management Module
# ==============================================================================
# This file defines all input variables with comprehensive customization options
# ==============================================================================

# ==============================================================================
# Required Variables
# ==============================================================================

variable "key_vault_name" {
  description = "The name of the Azure Key Vault for certificate storage"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key Vault name must be between 3-24 characters and contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.location))
    error_message = "Location must be a valid Azure region name."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group where resources will be created"
  type        = string
  
  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name cannot be empty."
  }
}

# ==============================================================================
# Key Vault Configuration
# ==============================================================================

variable "enabled_for_disk_encryption" {
  description = "Enable Key Vault for disk encryption"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft deleted"
  type        = number
  default     = 7
  
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90 days."
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for the Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_sku_name" {
  description = "The SKU name of the Key Vault (standard or premium)"
  type        = string
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

# ==============================================================================
# Network Access Control
# ==============================================================================

variable "network_acls" {
  description = "Network access control configuration for the Key Vault"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = optional(list(string))
    virtual_network_subnet_ids = optional(list(string))
  })
  default = null
  
  validation {
    condition = var.network_acls == null || (
      contains(["Allow", "Deny"], var.network_acls.default_action) &&
      contains(["AzureServices", "None"], var.network_acls.bypass)
    )
    error_message = "Network ACLs must have valid default_action and bypass values."
  }
}

# ==============================================================================
# Access Policies
# ==============================================================================

variable "certificate_permissions" {
  description = "Certificate permissions for the access policy"
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"]
  
  validation {
    condition = alltrue([
      for perm in var.certificate_permissions : 
      contains([
        "Get", "List", "Create", "Delete", "Update", "Import", "Backup", 
        "Restore", "Recover", "Purge", "ManageContacts", "ManageIssuers", 
        "SetIssuers", "DeleteIssuers"
      ], perm)
    ])
    error_message = "Invalid certificate permission specified."
  }
}

variable "key_permissions" {
  description = "Key permissions for the access policy"
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"]
  
  validation {
    condition = alltrue([
      for perm in var.key_permissions : 
      contains([
        "Get", "List", "Create", "Delete", "Update", "Import", "Backup", 
        "Restore", "Recover", "Purge", "WrapKey", "UnwrapKey", "Verify", "Sign"
      ], perm)
    ])
    error_message = "Invalid key permission specified."
  }
}

variable "secret_permissions" {
  description = "Secret permissions for the access policy"
  type        = list(string)
  default     = ["Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"]
  
  validation {
    condition = alltrue([
      for perm in var.secret_permissions : 
      contains([
        "Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"
      ], perm)
    ])
    error_message = "Invalid secret permission specified."
  }
}

variable "storage_permissions" {
  description = "Storage permissions for the access policy"
  type        = list(string)
  default     = ["Get", "List", "Delete", "Set", "Update", "RegenerateKey", "Recover", "Purge", "Backup", "Restore", "SetSas", "ListSas", "GetSas", "DeleteSas"]
  
  validation {
    condition = alltrue([
      for perm in var.storage_permissions : 
      contains([
        "Get", "List", "Delete", "Set", "Update", "RegenerateKey", "Recover", 
        "Purge", "Backup", "Restore", "SetSas", "ListSas", "GetSas", "DeleteSas"
      ], perm)
    ])
    error_message = "Invalid storage permission specified."
  }
}

variable "additional_access_policies" {
  description = "Additional access policies for other users/service principals"
  type = list(object({
    tenant_id = string
    object_id = string
    certificate_permissions = optional(list(string))
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  default = []
}

# ==============================================================================
# Self-Signed Certificates
# ==============================================================================

variable "self_signed_certificates" {
  description = "Map of self-signed certificates to create"
  type = map(object({
    exportable = optional(bool, true)
    key_size   = optional(number, 2048)
    key_type   = optional(string, "RSA")
    reuse_key  = optional(bool, true)
    days_before_expiry = optional(number, 30)
    extended_key_usage = optional(list(string), ["1.3.6.1.5.5.7.3.1"])
    key_usage = optional(list(string), ["digitalSignature", "keyEncipherment"])
    dns_names = list(string)
    emails    = optional(list(string), [])
    upns      = optional(list(string), [])
    subject   = string
    validity_in_months = optional(number, 12)
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for cert in values(var.self_signed_certificates) : 
      cert.key_size >= 2048 && cert.key_size <= 4096
    ])
    error_message = "Key size must be between 2048 and 4096 bits."
  }
}

# ==============================================================================
# Imported Certificates
# ==============================================================================

variable "imported_certificates" {
  description = "Map of certificates to import from files"
  type = map(object({
    certificate_file     = string
    certificate_password = optional(string)
  }))
  default = {}
}

# ==============================================================================
# Certificate Issuers
# ==============================================================================

variable "certificate_issuers" {
  description = "Map of certificate issuers to configure"
  type = map(object({
    provider_name = string
    account_id    = optional(string)
    password      = optional(string)
    admin_contacts = list(object({
      first_name = string
      last_name  = string
      email_address = string
      phone      = optional(string)
    }))
    organization_id = optional(string)
  }))
  default = {}
}

# ==============================================================================
# Certificate Contacts
# ==============================================================================

variable "certificate_contacts" {
  description = "List of certificate contacts for notifications"
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []
}

# ==============================================================================
# Certificate Secrets
# ==============================================================================

variable "certificate_secrets" {
  description = "Map of certificate secrets to store"
  type = map(object({
    secret_value     = string
    content_type     = optional(string, "application/x-pkcs12")
    not_before_date  = optional(string)
    expiration_date  = optional(string)
    purpose          = optional(string, "Certificate")
  }))
  default = {}
}

# ==============================================================================
# Private Endpoint Configuration
# ==============================================================================

variable "enable_private_endpoint" {
  description = "Enable private endpoint for Key Vault access"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The subnet ID for the private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for the private endpoint"
  type        = list(string)
  default     = []
}

# ==============================================================================
# Diagnostic Settings
# ==============================================================================

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for monitoring"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID for diagnostic logs"
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "The storage account ID for diagnostic logs"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default     = ["AuditEvent", "AzurePolicyEvaluationDetails"]
  
  validation {
    condition = alltrue([
      for category in var.diagnostic_log_categories : 
      contains([
        "AuditEvent", "AzurePolicyEvaluationDetails"
      ], category)
    ])
    error_message = "Invalid diagnostic log category specified."
  }
}

variable "diagnostic_retention_days" {
  description = "Number of days to retain diagnostic logs"
  type        = number
  default     = 30
  
  validation {
    condition     = var.diagnostic_retention_days >= 1 && var.diagnostic_retention_days <= 365
    error_message = "Diagnostic retention days must be between 1 and 365 days."
  }
}

# ==============================================================================
# Tags
# ==============================================================================

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
} 