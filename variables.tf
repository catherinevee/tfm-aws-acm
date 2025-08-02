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
}

variable "secondary_region" {
  description = "Secondary AWS region for cross-region certificate usage"
  type        = string
  default     = null
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
