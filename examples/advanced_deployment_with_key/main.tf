locals {
  subnetworks = flatten(values(data.google_compute_network.network)[*].subnetworks_self_links)
}

data "google_compute_network" "network" {
  for_each = toset(var.networks)
  name     = each.key
  project  = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  for_each  = toset(local.subnetworks)
  self_link = each.key
}

module "palo_alto_usc1_11" {
  source  = "r-teller/appliance-paloalto/google"
  version = "0.9.0-beta"

  project             = var.project_id
  firewall_name       = "palo-alto-usc1-11"
  region              = "us-central1"
  zone                = "us-central1-a"
  tags                = ["us-central1", "us-central1-a", "allow-gcp-iap", "allow-all-rfc1918", "allow-gcp-gfe", "ngfw"]
  deployment_mode     = ["bootstrap", "vm"]
  ssh_key             = file("./ssh_key.pub")
  mgmt_interface_swap = true

  interfaces = {
    0 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("outside", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("outside", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("outside", subnetwork.name)) && subnetwork.region == "us-central1"][0], 11),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("outside", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = true,
    },
    1 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("mgmt", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("mgmt", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("mgmt", subnetwork.name)) && subnetwork.region == "us-central1"][0], 11),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("mgmt", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = true,
    },
    2 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("inside", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("inside", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("inside", subnetwork.name)) && subnetwork.region == "us-central1"][0], 11),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("inside", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = false,
    },
    3 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("dmz", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("dmz", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("dmz", subnetwork.name)) && subnetwork.region == "us-central1"][0], 11),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("dmz", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = false,
    },
  }
}


module "palo_alto_usc1_12" {
  # source  = "r-teller/appliance-paloalto/google"
  # version = "0.9.0-beta"

  source = "../../."

  project             = var.project_id
  firewall_name       = "palo-alto-usc1-12"
  region              = "us-central1"
  zone                = "us-central1-a"
  tags                = ["us-central1", "us-central1-a", "allow-gcp-iap", "allow-all-rfc1918", "allow-gcp-gfe", "ngfw"]
  deployment_mode     = ["bootstrap", "vm"]
  ssh_key             = file("./ssh_key.pub")
  mgmt_interface_swap = true

  interfaces = {
    0 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("outside", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("outside", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("outside", subnetwork.name)) && subnetwork.region == "us-central1"][0], 12),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("outside", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = false,
    },
    1 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("mgmt", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("mgmt", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("mgmt", subnetwork.name)) && subnetwork.region == "us-central1"][0], 12),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("mgmt", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = true,
    },
    2 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("inside", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("inside", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("inside", subnetwork.name)) && subnetwork.region == "us-central1"][0], 12),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("inside", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = false,
    },
    3 = {
      network             = [for network in data.google_compute_network.network : network.name if 0 < length(regexall("dmz", network.name))][0],
      subnetwork          = [for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.name if 0 < length(regexall("dmz", subnetwork.name)) && subnetwork.region == "us-central1"][0],
      internalAddress     = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("dmz", subnetwork.name)) && subnetwork.region == "us-central1"][0], 12),
      loadbalancerAddress = cidrhost([for subnetwork in data.google_compute_subnetwork.subnetwork : subnetwork.ip_cidr_range if 0 < length(regexall("dmz", subnetwork.name)) && subnetwork.region == "us-central1"][0], -2),
      externalEnabled     = false,
    },
  }
}