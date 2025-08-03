# ==============================================================================
# Variables for AWS Certificate Manager Module
# ==============================================================================
# This file defines all input variables for configuring AWS ACM certificates
# ==============================================================================

variable "environment" {
  description = "Environment tag value for resource identification (e.g., dev, qa, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Map of tags to apply to all resources created by this module"
  type        = map(string)
  default     = {}
}

variable "certificates" {
  description = "Map of certificate configurations to create in ACM"
  type = map(object({
    domain_name               = string
    subject_alternative_names = optional(list(string), [])
    validation_method        = optional(string, "DNS")
    validation_options       = optional(map(string), {})
    tags                     = optional(map(string), {})
  }))
  default = {}
  
  validation {
    condition = alltrue([
      for cert_name, cert_config in var.certificates : 
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$", cert_name))
    ])
    error_message = "Certificate names must be valid identifiers (alphanumeric and hyphens only, cannot start or end with hyphen)."
  }
  
  validation {
    condition = alltrue([
      for cert_name, cert_config in var.certificates : 
      can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*$", cert_config.domain_name))
    ])
    error_message = "Domain names must be valid domain name format."
  }
  
  validation {
    condition = alltrue([
      for cert_name, cert_config in var.certificates : 
      contains(["DNS", "EMAIL"], cert_config.validation_method)
    ])
    error_message = "Validation method must be either 'DNS' or 'EMAIL'."
  }
}

variable "certificate_defaults" {
  description = "Default settings applied to all certificates unless overridden"
  type = object({
    validation_method         = optional(string, "DNS")
    subject_alternative_names = optional(list(string), [])
    validation_options       = optional(map(string), {})
    tags                     = optional(map(string), {})
  })
  default = {}
}

variable "wait_for_validation" {
  description = "Whether to wait for certificate validation to complete"
  type        = bool
  default     = true
}

variable "validation_record_fqdns" {
  description = "List of FQDNs that implement the validation"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "Primary AWS region where certificates will be created"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[1-9][0-9]*$", var.aws_region))
    error_message = "AWS region must be a valid region format (e.g., us-east-1, eu-west-1)."
  }
}

variable "secondary_region" {
  description = "Secondary AWS region for cross-region certificate usage"
  type        = string
  default     = null
  
  validation {
    condition     = var.secondary_region == null || can(regex("^[a-z]{2}-[a-z]+-[1-9][0-9]*$", var.secondary_region))
    error_message = "Secondary AWS region must be a valid region format (e.g., us-east-1, eu-west-1) or null."
  }
  
  validation {
    condition     = var.secondary_region == null || var.secondary_region != var.aws_region
    error_message = "Secondary region must be different from the primary region."
  }
}

variable "dns_validation_options" {
  description = "Map of options for DNS validation method"
  type = map(object({
    ttl = optional(number, 300)
  }))
  default = {}
}

variable "email_validation_options" {
  description = "Map of options for EMAIL validation method"
  type = map(object({
    wait_for_validation = optional(bool, true)
  }))
  default = {}
}
