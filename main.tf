# AWS Certificate Manager Module
# Creates and manages SSL/TLS certificates using AWS ACM
# Supports DNS and email validation with cross-region deployment

# Certificate creation with validation
resource "aws_acm_certificate" "certificates" {
  for_each = var.certificates

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method

  # Handle certificate validation options
  dynamic "validation_option" {
    for_each = each.value.validation_options
    content {
      domain_name       = validation_option.key
      validation_domain = validation_option.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, each.value.tags, {
    Name = each.key
  })
}

# Certificate validation - waits for DNS/email validation to complete
resource "aws_acm_certificate_validation" "certificates" {
  for_each = var.wait_for_validation ? var.certificates : {}

  certificate_arn         = aws_acm_certificate.certificates[each.key].arn
  validation_record_fqdns = var.validation_record_fqdns

  timeouts {
    create = "5m"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation records for Route 53 (when DNS validation is used)
resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in flatten([
      for cert_key, cert in aws_acm_certificate.certificates : [
        for dvo in cert.domain_validation_options : {
          cert_key = cert_key
          domain   = dvo.domain_name
          name     = dvo.resource_record_name
          record   = dvo.resource_record_value
          type     = dvo.resource_record_type
        }
      ]
    ]) : "${dvo.cert_key}-${dvo.domain}" => dvo
    if var.create_route53_records
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.validation[each.value.cert_key].zone_id
}

# Look up Route 53 hosted zones for DNS validation
data "aws_route53_zone" "validation" {
  for_each = var.create_route53_records ? var.certificates : {}

  name         = each.value.domain_name
  private_zone = false
} 