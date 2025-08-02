provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-certificates-rg"
  location = "eastus"
}

module "certificate_management" {
  source = "../../"

  key_vault_name      = "example-cert-vault"
  location           = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Enable security features
  enable_private_endpoint = true
  min_tls_version        = "TLS1_2"
  purge_protection_enabled = true

  # Network configuration
  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["10.0.0.0/16"]
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }

  # Self-signed certificates
  self_signed_certificates = {
    "webapp-cert" = {
      dns_names           = ["example.com", "*.example.com"]
      subject            = "CN=example.com"
      validity_in_months = 12
      key_size           = 4096
      exportable         = true
      key_type          = "RSA"
      reuse_key         = false
      days_before_expiry = 30
    }
  }

  tags = {
    Environment = "Production"
    Department  = "IT"
    CostCenter  = "12345"
  }
}

# Example subnet for private endpoint
resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location           = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  private_endpoint_network_policies = "Enabled"  # Updated for latest Azure provider
}
