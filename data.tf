# ==============================================================================
# Data Sources
# ==============================================================================

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "certificate_group" {
  name = var.resource_group_name
}

# Get existing certificate issuer if specified
data "azurerm_key_vault_certificate_issuer" "existing" {
  for_each     = tomap(var.existing_issuers != null ? var.existing_issuers : {})
  name         = each.key
  key_vault_id = azurerm_key_vault.certificate_vault.id
}
