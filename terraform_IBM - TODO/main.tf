variable "ibmcloud_api_key" {}
variable "iaas_classic_username" {}
variable "iaas_classic_api_key" {}
variable "region" {}

provider "ibm" {
ibmcloud_api_key = var.ibmcloud_api_key
generation = 1
region = var.region
iaas_classic_username = var.iaas_classic_username
iaas_classic_api_key  = var.iaas_classic_api_key
}
/*
data "ibm_space" "spacedata" {
  space = "dev"   # this will be different if you aren't is this space
  org   = "andrea.bortolossi@icloud.com" # this will be different if you aren't is this org
}

resource "ibm_service_instance" "service_instance" {
  name       = "test"
  space_guid = data.ibm_space.spacedata.id
  service    = "speech_to_text"
  plan       = "lite"
  tags       = ["cluster-service", "cluster-bind"]
}
*/

// DATACENTER CODES: https://cloud.ibm.com/docs/overview?topic=overview-locations&locale=en
resource "ibm_compute_vm_instance" "twc_terraform_sample" {
    hostname = "twc-terraform-sample-name"
    domain = "bar.example.com"
    os_reference_code = "DEBIAN_8_64"
    datacenter = "LON04"
    network_speed = 10
    hourly_billing = true
    private_network_only = false
    cores = 1
    memory = 1024
    disks = [25, 10, 20]
    user_metadata = "{\"value\":\"newvalue\"}"
    dedicated_acct_host_only = true
    local_disk = false
    public_vlan_id = 1391277
    private_vlan_id = 7721931
    private_security_group_ids = [576973]
}
