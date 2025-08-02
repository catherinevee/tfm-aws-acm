variables {
  key_vault_name      = "test-cert-vault"
  location           = "eastus"
  resource_group_name = "test-rg"
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  use_msi                   = false
}

run "setup" {
  command = plan

  assert {
    condition     = azurerm_key_vault.certificate_vault.name == var.key_vault_name
    error_message = "Key Vault name does not match input"
  }

  assert {
    condition     = azurerm_key_vault.certificate_vault.location == var.location
    error_message = "Key Vault location does not match input"
  }

  assert {
    condition     = length(azurerm_key_vault.certificate_vault.network_acls) > 0
    error_message = "Network ACLs should be configured"
  }
}
