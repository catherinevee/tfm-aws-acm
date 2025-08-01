# ==============================================================================
# Variables for Advanced Certificate Management Example
# ==============================================================================
# This file defines variables for the advanced example configuration
# ==============================================================================

# ==============================================================================
# Azure Configuration
# ==============================================================================

variable "location" {
  description = "Azure region for deployment"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-certificate-management-advanced"
}

# ==============================================================================
# Key Vault Configuration
# ==============================================================================

variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
  default     = "kv-cert-advanced"
}

variable "key_vault_sku_name" {
  description = "SKU name for the Key Vault"
  type        = string
  default     = "premium"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days"
  type        = number
  default     = 30
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90 days."
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection"
  type        = bool
  default     = true
}

variable "enabled_for_disk_encryption" {
  description = "Enable disk encryption"
  type        = bool
  default     = true
}

# ==============================================================================
# Network Configuration
# ==============================================================================

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "private_subnet_prefix" {
  description = "Address prefix for the private subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "public_subnet_prefix" {
  description = "Address prefix for the public subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "allowed_ip_ranges" {
  description = "Allowed IP ranges for Key Vault access"
  type        = list(string)
  default     = ["10.0.0.0/8", "192.168.0.0/16"]
}

# ==============================================================================
# Certificate Configuration
# ==============================================================================

variable "self_signed_certificates" {
  description = "Configuration for self-signed certificates"
  type = map(object({
    dns_names = list(string)
    subject   = string
    key_size  = optional(number, 2048)
    validity_in_months = optional(number, 12)
    days_before_expiry = optional(number, 30)
  }))
  default = {
    "api-production" = {
      dns_names = ["api.example.com", "api.prod.example.com"]
      subject   = "CN=api.example.com"
      key_size  = 4096
      validity_in_months = 24
      days_before_expiry = 60
    }
    "web-production" = {
      dns_names = ["www.example.com", "example.com"]
      subject   = "CN=www.example.com"
      key_size  = 2048
      validity_in_months = 12
      days_before_expiry = 30
    }
  }
}

variable "certificate_contacts" {
  description = "Certificate contacts for notifications"
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = [
    {
      email = "admin@example.com"
      name  = "System Administrator"
      phone = "+1-555-0123"
    }
  ]
}

variable "certificate_secrets" {
  description = "Certificate secrets to store"
  type = map(object({
    secret_value = string
    content_type = optional(string, "text/plain")
    purpose      = optional(string, "Certificate")
  }))
  default = {
    "api-key" = {
      secret_value = "your-api-key-here"
      content_type = "text/plain"
      purpose      = "API Authentication"
    }
  }
}

# ==============================================================================
# Certificate Issuer Configuration
# ==============================================================================

variable "certificate_issuers" {
  description = "Certificate issuers configuration"
  type = map(object({
    provider_name = string
    account_id    = optional(string)
    password      = optional(string)
    admin_contacts = list(object({
      first_name    = string
      last_name     = string
      email_address = string
      phone         = optional(string)
    }))
    organization_id = optional(string)
  }))
  default = {}
}

# ==============================================================================
# Monitoring Configuration
# ==============================================================================

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = "law-cert-example"
}

variable "storage_account_name" {
  description = "Name of the storage account for diagnostics"
  type        = string
  default     = "stcert"
}

variable "diagnostic_retention_days" {
  description = "Diagnostic retention days"
  type        = number
  default     = 90
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
  default = {
    Environment = "Production"
    Project     = "Advanced Certificate Management"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
    Compliance  = "SOC2"
    ManagedBy   = "Terraform"
  }
} 