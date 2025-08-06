# Local Variables for AWS Certificate Manager Module
# Defines local variables for consistent configuration and processing

locals {
  # Default tags applied to all resources
  default_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Module      = "aws-acm"
      ManagedBy   = "terraform"
    }
  )

  # Normalized certificate configurations
  certificates = {
    for name, cert in coalesce(var.certificates, {}) : name => {
      # Ensure domain names and SANs are lowercase
      domain_name = lower(cert.domain_name)
      subject_alternative_names = [
        for san in coalesce(cert.subject_alternative_names, []) : lower(san)
      ]
      # Certificate validation settings
      validation_method = coalesce(cert.validation_method, "DNS")
      validation_options = coalesce(cert.validation_options, {})
      # Merge default and custom tags
      tags = merge(local.default_tags, coalesce(cert.tags, {}))
    }
  }

  # Helper flag for DNS validation usage
  using_dns_validation = length([
    for cert in local.certificates : cert
    if cert.validation_method == "DNS"
  ]) > 0
}