# ==============================================================================
# General Configuration
# ==============================================================================

variable "environment" {
  description = "Environment name for tagging and naming purposes"
  type        = string
  default     = "dev"
  
  validation {
    condition     = can(regex("^(dev|qa|staging|prod)$", var.environment))
    error_message = "Environment must be one of: dev, qa, staging, prod."
  }
}

variable "existing_issuers" {
  description = "Map of existing certificate issuers to use"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Network Security Configuration
# ==============================================================================

variable "enable_private_endpoint" {
  description = "Enable private endpoint for Key Vault"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "enable_rbac_authorization" {
  description = "Enable RBAC authorization for Key Vault"
  type        = bool
  default     = false
}

variable "min_tls_version" {
  description = "Minimum supported TLS version"
  type        = string
  default     = "TLS1_2"
  
  validation {
    condition     = can(regex("^TLS1_[2-3]$", var.min_tls_version))
    error_message = "Minimum TLS version must be TLS1_2 or TLS1_3."
  }
}

# ==============================================================================
# Monitoring Configuration
# ==============================================================================

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for Key Vault"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}
