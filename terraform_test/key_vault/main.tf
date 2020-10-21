
locals {
  rgn     = "test-keyvault"            # Resource Group Name
  region  = "westeurope"                        # Selected Azure location where run the example

  # MYSQL SERVER CONFIGURATIONS
  D_db_names              = ["mypgsqldb"]
  D_fw_rules          = [{ name = "test1", start_ip = "0.0.0.0", end_ip = "0.0.0.0" }]
}

# define terraform provider
terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = ">=2.7"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = local.region
}

module network {
  source                  = "../../modules/network"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  prefix                  = "mynetwork"
  address_space           = "10.0.0.0/16"
  management_vlan         = "10.0.3.0/24"
  production_vlan         = "10.0.1.0/24"
  test_vlan               = "10.0.2.0/24"
}

module "postgresql" {
  source = "../../modules/azure_postgreSQL"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  server_name = "mybortolodbprova"
  sku_name    = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  administrator_login          = "psqladminun"
  administrator_password       = "${data.azurerm_key_vault_secret.test.value}"
  server_version               = "9.6"
  ssl_enforcement_enabled      = true
  db_names                     = local.D_db_names
  db_charset                   = "UTF8"
  db_collation                 = "English_United States.1252"

  firewall_rule_prefix = "firewall"
  firewall_rules       = local.D_fw_rules

  vnet_rule_name_prefix = "vnet-db-rule"
  vnet_rules = [
    { name = "subnet1", subnet_id = module.network.production_subnet_id }
  ]
}

module keyvault {
  source              = "../../modules/keyvault"
  name                = "keyvaultbortolo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enabled_for_deployment          = var.kv-vm-deployment
  enabled_for_disk_encryption     = var.kv-disk-encryption
  enabled_for_template_deployment = var.kv-template-deployment

  tags = {
    environment = "test"
  }

  policies = {
    full = {
      tenant_id               = var.azure_tenant_id #Set the tenant ID as environment variable
      object_id               = var.kv-full-object-id
      key_permissions         = var.kv-key-permissions-full
      secret_permissions      = var.kv-secret-permissions-full
      certificate_permissions = var.kv-certificate-permissions-full
      storage_permissions     = var.kv-storage-permissions-full
    }
  }

  secrets = var.kv-secrets

}


data "azurerm_key_vault_secret" "test" {
  key_vault_id = module.keyvault.key-vault-id
  name      = "sqldb"
}

output "secret_value" {
  value = "${data.azurerm_key_vault_secret.test.value}"
}
