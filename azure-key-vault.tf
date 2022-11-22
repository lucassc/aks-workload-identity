resource "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  location            = azurerm_resource_group.environment_rg.location
  resource_group_name = azurerm_resource_group.environment_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  sku_name                    = "standard"
  enabled_for_disk_encryption = true
}

data "azuread_service_principal" "app" {
  application_id = azuread_application.app.application_id
}

resource "azurerm_key_vault_access_policy" "key_vault_access_policy" {

  key_vault_id = azurerm_key_vault.key_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azuread_service_principal.app.id

  secret_permissions = [
    "Get",
    "List"
  ]
}
