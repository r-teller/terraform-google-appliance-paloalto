locals {
  bootstrap_enabled = 0 < length(setintersection(["all", "bootstrap"], var.deployment_mode)) ? 1 : 0
  vm_enabled        = 0 < length(setintersection(["all", "vm"], var.deployment_mode)) ? 1 : 0

  # This configuration is only used if bootstrap_enabled
  _palo_config = [for key, interface in var.interfaces : {
    network_name      = substr(interface.network, 0, 31) // network name is used for zone and max length is 31 char
    ipv4_subnet_mask  = "/${split("/", data.google_compute_subnetwork.subnetwork[key].ip_cidr_range)[1]}"
    ipv4_gateway      = cidrhost(data.google_compute_subnetwork.subnetwork[key].ip_cidr_range, 1)
    ipv4_address      = google_compute_address.internal_address[key].address
    ipv4_loadbalancer = interface.loadbalancerAddress
    static_routes     = interface.staticRoutes
  } if(var.mgmt_interface_swap && tonumber(key) != 1 || !(var.mgmt_interface_swap && tonumber(key) != 0))]

  palo_config = [for i in range(length(local._palo_config)) : merge({ name : "ethernet1/${i + 1}" }, local._palo_config[i])]

  mgmt_interface_swap = var.mgmt_interface_swap && local.bootstrap_enabled == 0 ? "enable" : null
  op_command_modes    = var.mgmt_interface_swap ? "mgmt-interface-swap" : ""

  service_account = var.service_account != null ? var.service_account : data.google_compute_default_service_account.compute_default_service_account.email
}

data "google_compute_default_service_account" "compute_default_service_account" {
  project = var.project
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork
data "google_compute_subnetwork" "subnetwork" {
  for_each = var.interfaces

  name    = each.value.subnetwork
  project = var.project
  region  = var.region
}

resource "tls_private_key" "default" {
  count     = var.ssh_key == null && var.create_private_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  count    = var.ssh_key == null && var.create_private_key && var.write_private_key_to_file ? 1 : 0
  content  = tls_private_key.default[0].private_key_pem
  filename = "./${var.firewall_name}.key"
}

resource "google_storage_bucket" "bucket" {
  count                       = local.bootstrap_enabled
  name                        = "${var.project}-${var.zone}-${var.firewall_name}"
  project                     = var.project
  location                    = var.region
  storage_class               = "REGIONAL"
  uniform_bucket_level_access = false // uniform bucket access has to be disabled for this bucket or Palo VM will not be able to bootstrap
}

resource "google_storage_bucket_object" "config" {
  count   = local.bootstrap_enabled
  name    = "config/"
  content = "..."
  bucket  = google_storage_bucket.bucket[0].name
  depends_on = [
    google_storage_bucket.bucket
  ]
}

# https://docs.paloaltonetworks.com/vm-series/9-0/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/sample-init-cfgtxt-file.html#id114bde92-3176-4c7c-a68a-eadfff80cb29
resource "google_storage_bucket_object" "bootstrap" {
  count = local.bootstrap_enabled
  name  = "config/bootstrap.xml"
  content = templatefile("${path.module}/bootstrap.tmpl",
    {
      "interfaces" : local.palo_config,
      "lb_config" : [for x in local.palo_config : x if x.ipv4_loadbalancer != null]
    }
  )
  bucket = google_storage_bucket.bucket[0].name
}


resource "local_file" "bootstrap_xml" {
  count    = local.bootstrap_enabled
  filename = "bootstrap.xml"
  content = templatefile("${path.module}/bootstrap.tmpl",
    {
      "interfaces" : local.palo_config,
      "lb_config" : [for x in local.palo_config : x if x.ipv4_loadbalancer != null]
    }
  )
}

# https://docs.paloaltonetworks.com/vm-series/9-0/vm-series-deployment/bootstrap-the-vm-series-firewall/create-the-init-cfgtxt-file/sample-init-cfgtxt-file.html#id114bde92-3176-4c7c-a68a-eadfff80cb29
resource "google_storage_bucket_object" "init_cfg" {
  count = local.bootstrap_enabled
  name  = "config/init-cfg.txt"
  content = templatefile("${path.module}/init-cfg.tmpl",
    {
      "op-command-modes" : local.op_command_modes,
    }
  )
  bucket = google_storage_bucket.bucket[0].name
}

resource "google_storage_bucket_object" "content" {
  count   = local.bootstrap_enabled
  name    = "content/"
  content = "..."
  bucket  = google_storage_bucket.bucket[0].name
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_storage_bucket_object" "software" {
  count   = local.bootstrap_enabled
  name    = "software/"
  content = "..."
  bucket  = google_storage_bucket.bucket[0].name
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_storage_bucket_object" "pulgins" {
  count   = local.bootstrap_enabled
  name    = "pulgins/"
  content = "..."
  bucket  = google_storage_bucket.bucket[0].name
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_storage_bucket_object" "license" {
  count   = local.bootstrap_enabled
  name    = "license/"
  content = "..."
  bucket  = google_storage_bucket.bucket[0].name
  depends_on = [
    google_storage_bucket.bucket
  ]
}

resource "google_compute_address" "external_address" {
  for_each     = { for k, v in var.interfaces : k => v if v.externalEnabled }
  name         = "${each.value.network}-${var.firewall_name}-ext"
  project      = var.project
  region       = var.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
}


resource "google_compute_address" "internal_address" {
  for_each     = var.interfaces
  name         = "${each.value.network}-${var.firewall_name}-int"
  project      = var.project
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = each.value.subnetwork
  address      = each.value.internalAddress
}

resource "google_compute_instance" "firewall" {
  count                     = local.vm_enabled
  name                      = var.firewall_name
  project                   = var.project
  machine_type              = var.machine_type
  zone                      = var.zone
  deletion_protection       = var.deletion_protection
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = var.tags

  metadata = {
    vmseries-bootstrap-gce-storagebucket = 0 < local.bootstrap_enabled ? google_storage_bucket.bucket[0].name : null
    mgmt-interface-swap                  = local.mgmt_interface_swap
    serial-port-enable                   = true
    block-project-ssh-keys               = var.block_project_ssh_keys
    ssh-keys                             = var.ssh_key != null ? "admin:${var.ssh_key}" : "admin:${tls_private_key.default[0].public_key_openssh}"
  }

  service_account {
    email  = local.service_account
    scopes = var.scopes
  }

  dynamic "network_interface" {
    for_each = var.interfaces
    content {
      network_ip = network_interface.value.internalAddress
      subnetwork = data.google_compute_subnetwork.subnetwork[network_interface.key].id
      dynamic "access_config" {
        for_each = network_interface.value.externalEnabled ? [1] : []
        content {
          nat_ip = [
            for external_address in google_compute_address.external_address : external_address.address
          if 0 < length(regexall(network_interface.value.network, external_address.name))][0]
        }
      }
    }
  }

  boot_disk {
    initialize_params {
      image = var.image
      type  = "pd-ssd"
    }
  }

  depends_on = [
    google_storage_bucket_object.init_cfg,
    google_storage_bucket_object.bootstrap,
  ]
}