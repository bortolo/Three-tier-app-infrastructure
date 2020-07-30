
resource "azurerm_postgresql_server" "main" {
  name                = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "B_Gen5_1"
  version    = "9.6"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  //public_network_access_enabled    = false
  ssl_enforcement_enabled          = false
  //ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_database" "main" {
  name                = "mypgsqldb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.main.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "main" {
  name                = "office"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
