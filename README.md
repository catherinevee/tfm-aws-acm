# Azure Certificate Management Module (AWS ACM Equivalent)

This Terraform module provides comprehensive certificate management functionality for Azure, equivalent to AWS Certificate Manager (ACM). It uses Azure Key Vault as the primary certificate store and management service.

## Features

- **Azure Key Vault Integration**: Secure certificate storage and management
- **Self-Signed Certificates**: Create development and testing certificates
- **Certificate Import**: Import existing certificates from files
- **Certificate Issuers**: Configure certificate authorities for automatic issuance
- **Certificate Contacts**: Set up notification contacts for certificate events
- **Certificate Secrets**: Store certificate-related secrets
- **Private Endpoints**: Secure access through private networking
- **Diagnostic Settings**: Comprehensive monitoring and logging
- **Access Policies**: Fine-grained access control
- **Network ACLs**: Network-level access restrictions

## Quick Start

### Basic Usage

```hcl
module "certificate_management" {
  source = "./tfm-aws-acm"

  key_vault_name      = "my-cert-vault"
  location           = "eastus"
  resource_group_name = "my-resource-group"

  # Create a self-signed certificate
  self_signed_certificates = {
    "web-app-cert" = {
      dns_names = ["example.com", "www.example.com"]
      subject   = "CN=example.com"
      validity_in_months = 12
    }
  }

  tags = {
    Environment = "Production"
    Project     = "Web Application"
  }
}
```

### Advanced Usage

```hcl
module "certificate_management" {
  source = "./tfm-aws-acm"

  key_vault_name      = "my-secure-cert-vault"
  location           = "eastus"
  resource_group_name = "my-resource-group"

  # Key Vault Configuration
  soft_delete_retention_days = 30
  purge_protection_enabled   = true
  key_vault_sku_name         = "premium"

  # Network Access Control
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["10.0.0.0/8", "192.168.0.0/16"]
    virtual_network_subnet_ids = ["/subscriptions/.../subnets/private"]
  }

  # Self-Signed Certificates
  self_signed_certificates = {
    "api-cert" = {
      dns_names = ["api.example.com"]
      subject   = "CN=api.example.com"
      key_size  = 4096
      validity_in_months = 24
      days_before_expiry = 60
    }
    "wildcard-cert" = {
      dns_names = ["*.example.com", "example.com"]
      subject   = "CN=*.example.com"
      key_size  = 2048
      validity_in_months = 12
    }
  }

  # Imported Certificates
  imported_certificates = {
    "existing-cert" = {
      certificate_file     = "./certs/existing-cert.pfx"
      certificate_password = "password123"
    }
  }

  # Certificate Issuers
  certificate_issuers = {
    "digicert" = {
      provider_name = "DigiCert"
      account_id    = "your-digicert-account"
      password      = "your-digicert-password"
      admin_contacts = [
        {
          first_name    = "John"
          last_name     = "Doe"
          email_address = "john.doe@example.com"
          phone         = "+1-555-0123"
        }
      ]
    }
  }

  # Certificate Contacts
  certificate_contacts = [
    {
      email = "admin@example.com"
      name  = "System Administrator"
      phone = "+1-555-0123"
    }
  ]

  # Private Endpoint
  enable_private_endpoint = true
  private_endpoint_subnet_id = "/subscriptions/.../subnets/private"
  private_dns_zone_ids = ["/subscriptions/.../privatednszones/privatelink.vaultcore.azure.net"]

  # Diagnostic Settings
  enable_diagnostic_settings = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"
  diagnostic_retention_days  = 90

  tags = {
    Environment = "Production"
    Project     = "Secure Web Application"
    Owner       = "DevOps Team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

### Required Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| key_vault_name | The name of the Azure Key Vault for certificate storage | `string` | n/a | yes |
| location | The Azure region where resources will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group where resources will be created | `string` | n/a | yes |

### Key Vault Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enabled_for_disk_encryption | Enable Key Vault for disk encryption | `bool` | `false` | no |
| soft_delete_retention_days | The number of days that items should be retained for once soft deleted | `number` | `7` | no |
| purge_protection_enabled | Enable purge protection for the Key Vault | `bool` | `false` | no |
| key_vault_sku_name | The SKU name of the Key Vault (standard or premium) | `string` | `"standard"` | no |

### Network Access Control

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network_acls | Network access control configuration for the Key Vault | `object` | `null` | no |

### Access Policies

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate_permissions | Certificate permissions for the access policy | `list(string)` | `["Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"]` | no |
| key_permissions | Key permissions for the access policy | `list(string)` | `["Get", "List", "Create", "Delete", "Update", "Import", "Backup", "Restore", "Recover", "Purge"]` | no |
| secret_permissions | Secret permissions for the access policy | `list(string)` | `["Get", "List", "Set", "Delete", "Backup", "Restore", "Recover", "Purge"]` | no |
| storage_permissions | Storage permissions for the access policy | `list(string)` | `["Get", "List", "Delete", "Set", "Update", "RegenerateKey", "Recover", "Purge", "Backup", "Restore", "SetSas", "ListSas", "GetSas", "DeleteSas"]` | no |
| additional_access_policies | Additional access policies for other users/service principals | `list(object)` | `[]` | no |

### Self-Signed Certificates

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| self_signed_certificates | Map of self-signed certificates to create | `map(object)` | `{}` | no |

### Imported Certificates

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| imported_certificates | Map of certificates to import from files | `map(object)` | `{}` | no |

### Certificate Issuers

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate_issuers | Map of certificate issuers to configure | `map(object)` | `{}` | no |

### Certificate Contacts

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate_contacts | List of certificate contacts for notifications | `list(object)` | `[]` | no |

### Certificate Secrets

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate_secrets | Map of certificate secrets to store | `map(object)` | `{}` | no |

### Private Endpoint Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_private_endpoint | Enable private endpoint for Key Vault access | `bool` | `false` | no |
| private_endpoint_subnet_id | The subnet ID for the private endpoint | `string` | `null` | no |
| private_dns_zone_ids | List of private DNS zone IDs for the private endpoint | `list(string)` | `[]` | no |

### Diagnostic Settings

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_diagnostic_settings | Enable diagnostic settings for monitoring | `bool` | `false` | no |
| log_analytics_workspace_id | The Log Analytics workspace ID for diagnostic logs | `string` | `null` | no |
| storage_account_id | The storage account ID for diagnostic logs | `string` | `null` | no |
| diagnostic_log_categories | List of diagnostic log categories to enable | `list(string)` | `["AuditEvent", "AzurePolicyEvaluationDetails"]` | no |
| diagnostic_retention_days | Number of days to retain diagnostic logs | `number` | `30` | no |

### Tags

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key_vault_id | The ID of the Azure Key Vault |
| key_vault_name | The name of the Azure Key Vault |
| key_vault_uri | The URI of the Azure Key Vault |
| key_vault_resource_id | The resource ID of the Azure Key Vault |
| self_signed_certificates | Map of created self-signed certificates |
| imported_certificates | Map of imported certificates |
| all_certificates | Combined map of all certificates (self-signed and imported) |
| certificate_issuers | Map of configured certificate issuers |
| certificate_contacts | Certificate contacts configuration |
| certificate_secrets | Map of certificate secrets |
| private_endpoint_id | The ID of the private endpoint (if enabled) |
| private_endpoint_ip_address | The private IP address of the private endpoint (if enabled) |
| diagnostic_settings_id | The ID of the diagnostic settings (if enabled) |
| access_policies | Current access policies on the Key Vault |
| network_acls | Network access control configuration |
| summary | Summary of the certificate management module deployment |

## Examples

### Basic Example

See the `examples/basic/` directory for a simple implementation.

### Advanced Example

See the `examples/advanced/` directory for a comprehensive implementation with all features enabled.

## Security Considerations

1. **Access Control**: Use the principle of least privilege when configuring access policies
2. **Network Security**: Implement network ACLs to restrict access to trusted networks
3. **Private Endpoints**: Use private endpoints for secure access in production environments
4. **Monitoring**: Enable diagnostic settings to monitor certificate operations
5. **Backup**: Ensure certificates are properly backed up and can be restored
6. **Rotation**: Implement certificate rotation policies for production certificates

## Best Practices

1. **Naming Convention**: Use consistent naming conventions for certificates and resources
2. **Tagging**: Apply appropriate tags for cost management and resource organization
3. **Version Control**: Store Terraform configurations in version control
4. **State Management**: Use remote state storage with proper access controls
5. **Testing**: Test certificate deployments in non-production environments first
6. **Documentation**: Document certificate purposes and renewal procedures

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure the service principal has the necessary permissions
2. **Network Access**: Verify network ACLs allow access from your location
3. **Certificate Import**: Ensure certificate files are in the correct format
4. **Private Endpoints**: Verify DNS resolution for private endpoints

### Support

For issues and questions, please refer to:
- [Azure Key Vault Documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## License

This module is licensed under the MIT License. See the LICENSE file for details.