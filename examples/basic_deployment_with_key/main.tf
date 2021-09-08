module "palo_alto_usc1_31" {
  source  = "r-teller/appliance-paloalto/google"
  version = "0.9.0-beta"

  project             = var.project_id
  firewall_name       = "palo-alto-usc1-31"
  region              = "us-central1"
  zone                = "us-central1-a"
  tags                = ["us-central1", "us-central1-a", "allow-gcp-iap", "allow-all-rfc1918", "allow-gcp-gfe", "ngfw"]
  deployment_mode     = ["bootstrap", "vm"]
  ssh_key             = file("./ssh_key.pub")
  mgmt_interface_swap = true

  interfaces = {
    0 = {
      network             = "ngfw-poc-prod-vpc-outside-global",
      subnetwork          = "ngfw-poc-prod-outside-global-subnet-10-10-0-0-24",
      internalAddress     = "10.10.0.31",
      loadbalancerAddress = null, // If no loadbalancer address is specifed nat configuration for loadbalancer healthchecks ill not be created within bootstrap.xml
      externalEnabled     = false, // If set to false an external address will not be reserved and associated for this interface, it can be later toggled to true or false in the future
    },
    1 = {
      network             = "ngfw-poc-prod-vpc-mgmt-global",
      subnetwork          = "ngfw-poc-prod-mgmt-global-subnet-10-255-0-0-24",
      internalAddress     = "10.255.0.31",
      loadbalancerAddress = null, // If no loadbalancer address is specifed nat configuration for loadbalancer healthchecks ill not be created within bootstrap.xml
      externalEnabled     = true,
    },
    2 = {
      network             = "ngfw-poc-prod-vpc-inside-global",
      subnetwork          = "ngfw-poc-prod-inside-global-subnet-172-16-0-0-24",
      internalAddress     = null, // If a null address is specified it will reserve the next available address
      loadbalancerAddress = "172.16.0.254",
      externalEnabled     = false,
    },
    3 = {
      network             = "ngfw-poc-prod-vpc-dmz-global",
      subnetwork          = "ngfw-poc-prod-dmz-global-subnet-192-168-0-0-24",
      internalAddress     = null, // If a null address is specified it will reserve the next available address
      loadbalancerAddress = "192.168.0.254",
      externalEnabled     = false,
    },
  }
}