# Azure Certificate Management Module Examples

This directory contains examples demonstrating how to use the Azure Certificate Management Module (AWS ACM equivalent) in different scenarios.

## Examples Overview

### Basic Example (`basic/`)

A simple implementation suitable for development and testing environments.

**Features:**
- Minimal configuration
- Single self-signed certificate
- Basic Key Vault setup
- Development-friendly settings

**Use Case:** Development, testing, proof of concept

### Advanced Example (`advanced/`)

A comprehensive implementation suitable for production environments.

**Features:**
- Full network security with private endpoints
- Multiple certificates (self-signed and imported)
- Certificate issuers configuration
- Comprehensive monitoring and diagnostics
- Production-grade security settings
- Certificate contacts and secrets management

**Use Case:** Production environments, enterprise deployments

## Getting Started

### Prerequisites

1. **Azure CLI**: Install and authenticate with Azure
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Terraform**: Install Terraform (version >= 1.0)
   ```bash
   # Download from https://www.terraform.io/downloads.html
   # or use package manager
   ```

3. **Required Permissions**: Ensure your Azure account has the following permissions:
   - Contributor role on the target subscription
   - Key Vault Contributor role
   - Network Contributor role (for advanced example)

### Quick Start with Basic Example

1. Navigate to the basic example:
   ```bash
   cd examples/basic
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

### Advanced Example Setup

1. Navigate to the advanced example:
   ```bash
   cd examples/advanced
   ```

2. Copy the example variables file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. Edit `terraform.tfvars` with your specific values:
   ```hcl
   # Update these values
   key_vault_name = "kv-cert-advanced-12345"
   location = "eastus"
   
   # Configure your certificates
   self_signed_certificates = {
     "api-production" = {
       dns_names = ["api.yourdomain.com"]
       subject   = "CN=api.yourdomain.com"
       key_size  = 4096
       validity_in_months = 24
     }
   }
   
   # Configure certificate contacts
   certificate_contacts = [
     {
       email = "admin@yourdomain.com"
       name  = "Your Name"
       phone = "+1-555-0123"
     }
   ]
   ```

4. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration Options

### Key Vault Settings

| Setting | Basic Example | Advanced Example | Description |
|---------|---------------|------------------|-------------|
| SKU | Standard | Premium | Key Vault service tier |
| Soft Delete | 7 days | 30 days | Retention period for deleted items |
| Purge Protection | Disabled | Enabled | Prevents permanent deletion |
| Network Access | Allow all | Restricted | Network access control |

### Certificate Types

#### Self-Signed Certificates
- **Development**: Quick setup for testing
- **Production**: Internal services, development environments
- **Configuration**: DNS names, validity period, key size

#### Imported Certificates
- **Use Case**: Existing certificates from external CAs
- **Format**: PFX/P12 files with password protection
- **Security**: Stored securely in Key Vault

#### Certificate Issuers
- **Providers**: DigiCert, GlobalSign, etc.
- **Automation**: Automatic certificate renewal
- **Integration**: Direct CA integration

### Security Features

#### Network Security
- **Private Endpoints**: Secure access from VNet
- **Network ACLs**: IP-based access restrictions
- **Firewall Rules**: Subnet-based access control

#### Access Control
- **RBAC**: Role-based access control
- **Access Policies**: Fine-grained permissions
- **Audit Logging**: Comprehensive activity tracking

#### Monitoring
- **Diagnostic Settings**: Log Analytics integration
- **Storage Logs**: Long-term log retention
- **Metrics**: Performance and usage monitoring

## Customization

### Adding Custom Certificates

```hcl
self_signed_certificates = {
  "custom-app" = {
    dns_names = ["app.yourdomain.com", "www.app.yourdomain.com"]
    subject   = "CN=app.yourdomain.com"
    key_size  = 2048
    validity_in_months = 12
    days_before_expiry = 30
    extended_key_usage = ["1.3.6.1.5.5.7.3.1"]  # Server Authentication
    key_usage = ["digitalSignature", "keyEncipherment"]
  }
}
```

### Configuring Certificate Issuers

```hcl
certificate_issuers = {
  "digicert" = {
    provider_name = "DigiCert"
    account_id    = "your-account-id"
    password      = "your-password"
    admin_contacts = [
      {
        first_name    = "John"
        last_name     = "Doe"
        email_address = "john.doe@yourdomain.com"
        phone         = "+1-555-0123"
      }
    ]
  }
}
```

### Setting Up Private Endpoints

```hcl
# Enable private endpoint
enable_private_endpoint = true
private_endpoint_subnet_id = "/subscriptions/.../subnets/private"
private_dns_zone_ids = ["/subscriptions/.../privatednszones/privatelink.vaultcore.azure.net"]
```

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Ensure proper Azure CLI authentication
   az login
   az account show
   ```

2. **Key Vault Name Conflicts**
   - Key Vault names must be globally unique
   - Use random suffixes or unique naming conventions

3. **Network Access Issues**
   - Verify IP ranges in network ACLs
   - Check private endpoint configuration
   - Ensure DNS resolution for private endpoints

4. **Certificate Import Errors**
   - Verify certificate file format (PFX/P12)
   - Check certificate password
   - Ensure certificate is not expired

### Useful Commands

```bash
# Check Key Vault status
az keyvault show --name <key-vault-name> --resource-group <resource-group>

# List certificates
az keyvault certificate list --vault-name <key-vault-name>

# Get certificate details
az keyvault certificate show --vault-name <key-vault-name> --name <certificate-name>

# Check diagnostic settings
az monitor diagnostic-settings list --resource <key-vault-id>
```

## Cleanup

To destroy the infrastructure:

```bash
# Basic example
cd examples/basic
terraform destroy

# Advanced example
cd examples/advanced
terraform destroy
```

**Note**: Key Vaults with purge protection enabled may require manual cleanup in the Azure portal.

## Support

For issues and questions:
- Check the [main module README](../README.md)
- Review [Azure Key Vault documentation](https://docs.microsoft.com/en-us/azure/key-vault/)
- Consult [Terraform Azure provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) 