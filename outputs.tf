# AWS Certificate Manager Module Outputs
# Certificate ARNs and validation information for integration with other services

# Certificate ARNs indexed by certificate name
output "certificate_arns" {
  description = "Map of certificate ARNs indexed by certificate name"
  value = {
    for name, cert in aws_acm_certificate.certificates : name => cert.arn
  }
}

# Certificate IDs for reference
output "certificate_ids" {
  description = "Map of certificate IDs indexed by certificate name"
  value = {
    for name, cert in aws_acm_certificate.certificates : name => cert.id
  }
}

# DNS validation records for manual Route 53 configuration
output "validation_records" {
  description = "DNS validation records for manual Route 53 setup"
  value = {
    for name, cert in aws_acm_certificate.certificates : name => [
      for dvo in cert.domain_validation_options : {
        domain_name           = dvo.domain_name
        resource_record_name  = dvo.resource_record_name
        resource_record_type  = dvo.resource_record_type
        resource_record_value = dvo.resource_record_value
      }
    ]
  }
}

# Certificate domain names
output "certificate_domains" {
  description = "Map of primary domain names indexed by certificate name"
  value = {
    for name, cert in aws_acm_certificate.certificates : name => cert.domain_name
  }
}

# Certificate status information
output "certificate_status" {
  description = "Map of certificate validation status indexed by certificate name"
  value = {
    for name, cert in aws_acm_certificate.certificates : name => cert.status
  }
} 