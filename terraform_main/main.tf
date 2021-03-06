# READY TO USE IMAGES ==========================================================

/*
appserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage
ansibleserverImage: /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage
nodejsserverImage:  /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage
webserverImage:     /subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/webserverImage
*/


# CONFIG =======================================================================

locals {
  rgn     = "example-three-tier-app"            # Resource Group Name
  region  = "westeurope"                        # Selected Azure location where run the example

  # JUMPHOST SERVER CONFIGURATIONS
  J_name              = "jumphost"
  J_hostname          = "jumphost"
  J_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/ansibleserverImage"
  J_quantity          = 1
  J_inbound_port      = ["22","9090","9100","3000"]
  J_outbound_port     = []
  J_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  J_enable_public_ip  = true
  J_environment_tag   = "management"
  J_disable_password_authentication = true
  J_vm_size           = "Standard_B1s"

  # WEB SERVER CONFIGURATIONS
  W_name              = "web"
  W_hostname          = "webhost"
  W_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/nodejsserverImage"
  W_inbound_port      = ["8081","9100"]
  W_outbound_port     = []
  W_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  W_enable_public_ip  = false
  W_environment_tag   = "web"

  # APP SERVER CONFIGURATIONS
  A_name              = "app"
  A_hostname          = "apphost"
  A_storage_image_reference_id = "/subscriptions/de2dd9f0-a856-4177-b9f8-9fe12d786b1a/resourceGroups/TemplatePackerGenerator/providers/Microsoft.Compute/images/appserverImage"
  A_inbound_port      = ["8080"]
  A_outbound_port     = []
  A_ssh_key           = "/Users/andreabortolossi/.ssh/id_rsa.pub"
  A_enable_public_ip  = false
  A_environment_tag   = "app"

  # MYSQL SERVER CONFIGURATIONS
  D_db_names              = ["mypgsqldb"]
  D_fw_rules          = [{ name = "test1", start_ip = "0.0.0.0", end_ip = "0.0.0.0" }]

}

# MAIN =========================================================================

provider "azurerm" {
  version = ">=2.7"
  features {}
}

resource "azurerm_resource_group" "rg" {
        name = local.rgn
        location = local.region
}

module network {
  source                  = "../modules/network"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  prefix                  = "mynetwork"
  address_space           = "10.0.0.0/16"
  management_vlan         = "10.0.3.0/24"
  production_vlan         = "10.0.1.0/24"
  test_vlan               = "10.0.2.0/24"
}

# MANAGEMENT ===================================================================

resource "azurerm_availability_set" "jumphost_HA" {
  name                = "jumphost_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalserver" {
  source                          = "../modules/generalserver"
  location                        = azurerm_resource_group.rg.location
  resource_group_name             = azurerm_resource_group.rg.name
  prefix                          = local.J_name
  subnet_id                       = module.network.management_subnet_id
  hostname                        = local.J_hostname
  storage_image_reference_id      = local.J_storage_image_reference_id
  number_of_servers               = local.J_quantity
  inbound_rules                   = local.J_inbound_port
  outbound_rules                  = local.J_outbound_port
  ssh_key                         = local.J_ssh_key
  enable_public_ip                = local.J_enable_public_ip
  environment_tag                 = local.J_environment_tag
  disable_password_authentication = local.J_disable_password_authentication
  availability_set_id             = azurerm_availability_set.jumphost_HA.id
  vm_size                         = local.J_vm_size
  username                        = var.username
  password                    = "${data.azurerm_key_vault_secret.server.value}"
  //password                    = var.password
  monitoring_tag                  = "no"
}

# LOAD BALANCER WEB ============================================================

module "web_lb" {
  source                  = "../modules/loadbalancer/web"
  prefix                  = "webLB"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  protocol                = "Tcp"
  frontend_port           = 80
  backend_port            = local.W_inbound_port[0]
}

# WEBSERVERS ===================================================================

resource "azurerm_availability_set" "webserver_HA" {
  name                = "webserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalwebserver" {
  source                      = "../modules/generalserver"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  prefix                      = local.W_name
  subnet_id                   = module.network.production_subnet_id
  hostname                    = local.W_hostname
  storage_image_reference_id  = local.W_storage_image_reference_id
  number_of_servers           = var.W_quantity
  inbound_rules               = local.W_inbound_port
  outbound_rules              = local.W_outbound_port
  ssh_key                     = local.W_ssh_key
  enable_public_ip            = local.W_enable_public_ip
  environment_tag             = local.W_environment_tag
  enable_backend_address_pool = true
  backend_address_pool_id     = module.web_lb.backend_address_pool_id
  availability_set_id         = azurerm_availability_set.webserver_HA.id
  vm_size                   = var.W_vm_size
  username                        = var.username
  password                    = "${data.azurerm_key_vault_secret.server.value}"
  //password                    = var.password
}

# DNS PRIVATE ZONE =============================================================

resource "azurerm_private_dns_zone" "example-private" {
  name                = "mydomain.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_a_record" "example" {
  name                = "test"
  zone_name           = azurerm_private_dns_zone.example-private.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.app_lb.private_ip_address]
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "private_DNS"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.example-private.name
  virtual_network_id    = module.network.main_virtual_network_id
}

# LOAD BALANCER INTERNAL =======================================================

module "app_lb" {
  source                  = "../modules/loadbalancer/app"
  prefix                  = "appLB"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  protocol                = "Tcp"
  frontend_port           = local.A_inbound_port[0]
  backend_port            = local.A_inbound_port[0]
  subnet_id               = module.network.production_subnet_id
}

# APPSERVERS ===================================================================

resource "azurerm_availability_set" "appserver_HA" {
  name                = "appserver_HA"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

module "generalappserver" {
  source                      = "../modules/generalserver"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  prefix                      = local.A_name
  subnet_id                   = module.network.production_subnet_id
  hostname                    = local.A_hostname
  storage_image_reference_id  = local.A_storage_image_reference_id
  number_of_servers           = var.A_quantity
  inbound_rules               = local.A_inbound_port
  outbound_rules              = local.A_outbound_port
  ssh_key                     = local.A_ssh_key
  enable_public_ip            = local.A_enable_public_ip
  environment_tag             = local.A_environment_tag
  enable_backend_address_pool = true
  backend_address_pool_id     = module.app_lb.backend_address_pool_id
  availability_set_id         = azurerm_availability_set.appserver_HA.id
  vm_size                     = var.A_vm_size
  username                    = var.username
  password                    = "${data.azurerm_key_vault_secret.server.value}"
  //password                    = var.password
}

# DATABASE =====================================================================

module "postgresql" {
  source = "../modules/azure_postgreSQL"

  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  server_name = "mybortolodbprova"
  sku_name    = "B_Gen5_1"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  administrator_login          = "psqladmin"
  administrator_password       = "${data.azurerm_key_vault_secret.db.value}"
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

# KEY VAULT =====================================================================

module keyvault {
  source              = "../modules/keyvault"
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

data "azurerm_key_vault_secret" "server" {
  key_vault_id = module.keyvault.key-vault-id
  name      = "serveradmin"
}

data "azurerm_key_vault_secret" "db" {
  key_vault_id = module.keyvault.key-vault-id
  name      = "sqldb"
}
