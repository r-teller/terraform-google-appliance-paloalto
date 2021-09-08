output "zone" {
  value = can(google_compute_instance.firewall[0]) ? google_compute_instance.firewall[0].zone : null
}
output "name" {
  value = can(google_compute_instance.firewall[0]) ? google_compute_instance.firewall[0].name : null
}
output "self_link" {
  value = can(google_compute_instance.firewall[0]) ? google_compute_instance.firewall[0].self_link : null
}
output "primary_network" {
  value = can(google_compute_instance.firewall[0]) ? google_compute_instance.firewall[0].network_interface[0].network : null
}
output "external_mgmt_address" {
  value = var.mgmt_interface_swap != "enable" && can(google_compute_address.external_address[0]) ? google_compute_address.external_address[0].address : var.mgmt_interface_swap == "enable" && can(google_compute_address.external_address[1]) ? google_compute_address.external_address[1].address : null
}

output "external_addresses" {
  value = google_compute_address.external_address
}

output "palo_config" {
  value = local.palo_config
}

output "api_key" {
  value = "PandasAreAwesome"
}