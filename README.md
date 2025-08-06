# AWS Certificate Manager (ACM) Terraform Module

Manages SSL/TLS certificates through AWS Certificate Manager with DNS or email validation. Handles cross-region deployment for CloudFront and regional load balancers.

## Resources Created

| Resource | Purpose | Notes |
|----------|---------|-------|
| `aws_acm_certificate` | SSL/TLS certificate | Primary certificate resource |
| `aws_acm_certificate_validation` | Validation tracking | Waits for DNS/email validation |
| `aws_route53_record` | DNS validation | CNAME records for domain validation |
| `aws_cloudwatch_metric_alarm` | Expiration alerts | Optional monitoring |
| `aws_sns_topic` | Notifications | Certificate expiry alerts |

## Features

- Certificate creation with DNS or email validation
- Cross-region deployment for CloudFront (us-east-1 requirement)
- Route 53 integration for automated DNS validation
- CloudWatch monitoring for expiration tracking
- Flexible certificate naming and SAN configuration

## Usage

### Basic Usage

```hcl
module "acm" {
  source = "github.com/catherinevee/tfm-aws-acm"

  certificates = {
    "api" = {
      domain_name = "api.example.com"
      subject_alternative_names = ["*.api.example.com"]
    }
  }

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

### CloudFront Certificate

CloudFront requires certificates in us-east-1 regardless of distribution edge locations:

```hcl
module "cloudfront_cert" {
  source = "github.com/catherinevee/tfm-aws-acm"
  
  aws_region = "us-east-1"  # Required for CloudFront
  
  certificates = {
    "website" = {
      domain_name = "www.example.com"
      subject_alternative_names = ["example.com"]
    }
  }
}
```

## Configuration

### Certificate Object

```hcl
certificates = {
  "cert-name" = {
    domain_name               = "example.com"
    subject_alternative_names = ["www.example.com", "api.example.com"]
    validation_method        = "DNS"  # or "EMAIL"
    validation_options       = {}     # Domain-specific validation settings
    tags                     = {}     # Certificate-specific tags
  }
}
```

### Regional Considerations

- **us-east-1**: Required for CloudFront distributions
- **Regional**: Use same region as your ALB/NLB for lower latency
- **Cross-region**: Enable `secondary_region` for disaster recovery

## Common Issues

### DNS Validation Timeouts
Check that your Route 53 hosted zone has the correct NS records in your domain registrar. DNS propagation can take up to 24 hours in some cases.

### Cross-Region Provider Issues
The module automatically configures the secondary region provider. Ensure your AWS credentials have permission for both regions.

### CloudFront Certificate Errors
CloudFront only accepts certificates from us-east-1. Set `aws_region = "us-east-1"` for CloudFront distributions.

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.13.0 |
| aws | ~> 6.2.0 |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arns | Certificate ARNs indexed by certificate name |
| validation_records | DNS validation records for manual configuration |
| expiration_dates | Certificate expiration timestamps |

## Examples

See the `examples/` directory for complete configurations:
- `basic/` - Single certificate with DNS validation
- `advanced/` - Multiple certificates with cross-region support
- `complete/` - Full feature demonstration with monitoring