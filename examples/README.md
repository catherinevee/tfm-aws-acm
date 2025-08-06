# AWS Certificate Manager Examples

Working examples for different deployment scenarios.

## Available Examples

### Basic (`basic/`)
Single certificate with DNS validation for development environments.

### Advanced (`advanced/`)  
Multiple certificates with cross-region support for production deployments.

## Quick Start

1. **Prerequisites**
   - AWS CLI configured with appropriate credentials
   - Terraform >= 1.13.0
   - Route 53 hosted zone (for DNS validation examples)

2. **Basic Example**
   ```bash
   cd examples/basic
   terraform init
   terraform apply
   ```

3. **Advanced Configuration**
   ```bash
   cd examples/advanced
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your domain names
   terraform init && terraform apply
   ```

## Certificate Configuration

### Basic Certificate
```hcl
certificates = {
  "website" = {
    domain_name = "example.com"
    subject_alternative_names = ["www.example.com"]
    validation_method = "DNS"
  }
}
```

### CloudFront Certificate
```hcl
# CloudFront certificates must be in us-east-1
aws_region = "us-east-1"

certificates = {
  "cdn" = {
    domain_name = "cdn.example.com"
    subject_alternative_names = ["*.cdn.example.com"]
  }
}
```

### Cross-Region Setup
```hcl
aws_region = "us-east-1"
secondary_region = "us-west-2"

certificates = {
  "api" = {
    domain_name = "api.example.com"
  }
}
```

## Common Issues

### DNS Validation Timeout
- Check Route 53 hosted zone configuration
- Verify domain ownership in registrar settings
- DNS propagation can take up to 24 hours

### CloudFront Certificate Errors
- Ensure certificates are created in us-east-1
- Verify domain name matches CloudFront distribution
- Check certificate status in ACM console

### Useful Commands
```bash
# Check certificate status
aws acm describe-certificate --certificate-arn <arn>

# List certificates in region
aws acm list-certificates --region us-east-1

# Check Route 53 records
aws route53 list-resource-record-sets --hosted-zone-id <zone-id>
```

## Cleanup

```bash
terraform destroy
```

## Support

- [AWS Certificate Manager Documentation](https://docs.aws.amazon.com/acm/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) 