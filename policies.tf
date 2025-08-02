# ==============================================================================
# Access Policies Configuration
# ==============================================================================

# Base access policy for Key Vault administrators
locals {
  admin_permissions = {
    certificate_permissions = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import",
      "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover",
      "Restore", "SetIssuers", "Update"
    ]
    key_permissions = [
      "Backup", "Create", "Delete", "Get", "Import", "List", "Purge",
      "Recover", "Restore", "Update"
    ]
    secret_permissions = [
      "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
    ]
    storage_permissions = []
  }
}

# Default access policy for the current service principal
resource "azurerm_key_vault_access_policy" "current_sp" {
  key_vault_id = azurerm_key_vault.certificate_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  dynamic "certificate_permissions" {
    for_each = var.certificate_permissions != null ? [1] : []
    content {
      certificate_permissions = var.certificate_permissions
    }
  }

  dynamic "key_permissions" {
    for_each = var.key_permissions != null ? [1] : []
    content {
      key_permissions = var.key_permissions
    }
  }

  dynamic "secret_permissions" {
    for_each = var.secret_permissions != null ? [1] : []
    content {
      secret_permissions = var.secret_permissions
    }
  }

  dynamic "storage_permissions" {
    for_each = var.storage_permissions != null ? [1] : []
    content {
      storage_permissions = var.storage_permissions
    }
  }
}
