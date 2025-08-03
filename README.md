# AWS Certificate Manager (ACM) Terraform Module

A comprehensive Terraform module for managing SSL/TLS certificates using AWS Certificate Manager (ACM). This module provides functionality for creating, importing, and managing certificates with cross-region support.

## Resource Map

This module creates the following AWS resources:

### Core Certificate Resources
| Resource Type | Purpose | Required | Description |
|--------------|---------|----------|-------------|
| `aws_acm_certificate` | Core | Yes | Primary SSL/TLS certificate resource |
| `aws_acm_certificate_validation` | Core | Yes | Certificate validation management and status tracking |
| `aws_acm_certificate_validation` (secondary) | Core | No | Cross-region certificate validation for secondary region |

### DNS Validation Resources
| Resource Type | Purpose | Required | Description |
|--------------|---------|----------|-------------|
| `aws_route53_record` | DNS | No | DNS validation records for certificate verification |
| `aws_route53_zone` | DNS | No | Hosted zone for DNS validation (if not existing) |
| `aws_route53_record` (validation) | DNS | No | CNAME records for DNS validation tokens |

### Monitoring and Alerting
| Resource Type | Purpose | Required | Description |
|--------------|---------|----------|-------------|
| `aws_cloudwatch_metric_alarm` | Monitoring | No | Certificate expiration monitoring and alerts |
| `aws_sns_topic` | Notifications | No | SNS topic for certificate expiration notifications |
| `aws_sns_topic_subscription` | Notifications | No | Email subscription for certificate alerts |

### Data Sources
| Resource Type | Purpose | Required | Description |
|--------------|---------|----------|-------------|
| `data.aws_route53_zone` | DNS | No | Existing hosted zone lookup for DNS validation |
| `data.aws_caller_identity` | Identity | No | Current AWS account information |
| `data.aws_region` | Region | No | Current AWS region information |

### Resource Dependencies
- **Certificate Creation**: `aws_acm_certificate` → `aws_acm_certificate_validation`
- **DNS Validation**: `aws_acm_certificate` → `aws_route53_record` (validation records)
- **Monitoring**: `aws_acm_certificate` → `aws_cloudwatch_metric_alarm`
- **Cross-Region**: Primary region certificate → Secondary region validation

## Features

- **Certificate Management**: Create and manage SSL/TLS certificates
- **Multi-region Support**: Optional secondary region for cross-region usage
- **DNS Validation**: Automated DNS validation for certificates
- **Email Validation**: Support for email validation method
- **Monitoring**: Built-in expiration monitoring with CloudWatch
- **Tag Management**: Standardized tagging for all resources
- **Default Settings**: Configurable defaults for all certificates

## Usage

### Basic Example

```hcl
module "acm" {
  source  = "github.com/catherinevee/tfm-aws-acm"
  version = "~> 1.0"

  aws_region = "us-east-1"
  
  certificates = {
    "example-com" = {
      domain_name               = "example.com"
      subject_alternative_names = ["*.example.com"]
      validation_method        = "DNS"
    }
  }

  tags = {
    Environment = "production"
    Project     = "website"
    CostCenter  = "web-team"
    Owner       = "infrastructure"
  }
}
```

### Cross-Region Example

```hcl
module "acm_multi_region" {
  source  = "github.com/catherinevee/tfm-aws-acm"
  version = "~> 1.0"

  aws_region       = "us-east-1"
  secondary_region = "us-west-2"
  
  certificates = {
    "api-example-com" = {
      domain_name               = "api.example.com"
      subject_alternative_names = ["*.api.example.com"]
      validation_method        = "DNS"
      create_in_secondary     = true
    }
  }

  tags = {
    Environment = "production"
    Project     = "api-gateway"
    CostCenter  = "platform"
    Owner       = "platform-team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.13.0 |
| aws | ~> 6.2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 6.2.0 |
| aws.secondary | ~> 6.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | Primary AWS region for certificate creation | string | "us-east-1" | yes |
| secondary_region | Secondary region for cross-region certificates | string | null | no |
| certificates | Map of certificate configurations | map(object) | {} | yes |
| tags | Map of tags to apply to all resources | map(string) | {} | yes |
| certificate_defaults | Default settings for all certificates | object | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| certificate_arns | Map of certificate ARNs by name |
| validation_records | DNS validation records (when using DNS validation) |
| expiration_dates | Map of certificate expiration dates |
| validation_emails | List of validation emails (when using email validation) |

## Best Practices

1. **Region Selection**
   - Use us-east-1 for CloudFront distributions
   - Use the same region as your load balancer for ALB/NLB
   - Enable cross-region for disaster recovery

2. **Validation Methods**
   - Prefer DNS validation over email validation
   - Use Route 53 for automated DNS validation
   - Plan for validation token expiration

3. **Monitoring**
   - Enable CloudWatch alarms for expiration
   - Monitor validation status
   - Set up SNS notifications

4. **Security**
   - Use tags for access control
   - Implement proper IAM permissions
   - Enable AWS Config rules

## Troubleshooting

Common issues and solutions:

1. **Validation Timeout**
   - Check DNS propagation
   - Verify domain ownership
   - Ensure proper IAM permissions

2. **Cross-Region Issues**
   - Verify secondary region provider
   - Check resource quotas
   - Validate IAM roles

3. **CloudFront Integration**
   - Ensure certificates are in us-east-1
   - Check domain name matches
   - Verify SSL/TLS version support

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

Apache 2.0 Licensed. See LICENSE for full details.

## Additional Features

- **Certificate Import**: Import existing certificates from files
- **Certificate Monitoring**: Built-in CloudWatch monitoring and alerting
- **Cross-Region Support**: Deploy certificates across multiple AWS regions
- **DNS Validation**: Automated DNS validation with Route 53 integration
- **Email Validation**: Support for email-based certificate validation
- **Tag Management**: Comprehensive tagging for cost management and governance
- **Lifecycle Management**: Automatic certificate renewal and expiration handling

## Examples

### Basic Example

See the `examples/basic/` directory for a simple implementation.

### Advanced Example

See the `examples/advanced/` directory for a comprehensive implementation with all features enabled.

### Complete Example

See the `examples/complete/` directory for a full-featured implementation.

## Security Considerations

1. **Access Control**: Use the principle of least privilege when configuring IAM permissions
2. **Network Security**: Implement proper security groups and network ACLs
3. **Certificate Validation**: Prefer DNS validation over email validation for production
4. **Monitoring**: Enable CloudWatch alarms for certificate expiration
5. **Backup**: Ensure certificates are properly backed up and can be restored
6. **Rotation**: Implement certificate rotation policies for production certificates

## Best Practices

1. **Region Selection**: Use us-east-1 for CloudFront distributions
2. **Validation Methods**: Prefer DNS validation for automated renewal
3. **Tagging**: Apply appropriate tags for cost management and resource organization
4. **Version Control**: Store Terraform configurations in version control
5. **State Management**: Use remote state storage with proper access controls
6. **Testing**: Test certificate deployments in non-production environments first

## Troubleshooting

### Common Issues

1. **Validation Timeout**: Check DNS propagation and domain ownership
2. **Cross-Region Issues**: Verify secondary region provider configuration
3. **CloudFront Integration**: Ensure certificates are in us-east-1 region
4. **Permission Errors**: Ensure proper IAM permissions for ACM operations

### Support

For issues and questions, please refer to:
- [AWS Certificate Manager Documentation](https://docs.aws.amazon.com/acm/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This module is licensed under the Apache 2.0 License. See the LICENSE file for details.