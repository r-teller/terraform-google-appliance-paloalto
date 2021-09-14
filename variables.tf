
variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "firewall_name" {
  type = string
}

variable "service_account" {
  type    = string
  default = null
}

variable "create_private_key" {
  type    = bool
  default = false
}

variable "write_private_key_to_file" {
  type    = bool
  default = false
}

variable "ssh_key" {
  type    = string
  default = null
}
variable "block_project_ssh_keys" {
  type    = bool
  default = true
}
variable "mgmt_interface_swap" {
  type    = bool
  default = true
}

variable "deployment_mode" {
  type    = list(string)
  default = ["all"]
  validation {
    condition     = !(can(index([for key in var.deployment_mode : contains(["all", "bootstrap", "vm"], key)], false)))
    error_message = "One or more strings in Var.deployment_mode is not supported, supported strings are [all, boostratp, vm]."
  }
}

variable "interfaces" {
  type = map(object({
    externalEnabled     = bool,
    network             = string,
    subnetwork          = string,
    internalAddress     = string,
    loadbalancerAddress = string,
    staticRoutes = list(object({
      name             = string
      destinationRange = string
    })),
    })
  )
  validation {
    condition     = length(var.interfaces) >= 2 && length(var.interfaces) <= 8
    error_message = "Var.interfaces must contain between 2 and 8 interfaces."
  }
  validation {
    # Checks to see if any of the keys in the interface map are non-numbers
    # condition = (
    #   !(can(index([for key in keys(var.interfaces) : can(tonumber(key))], false)))
    # )
    condition     = alltrue([for key in keys(var.interfaces) : contains(range(0, length(var.interfaces)), tonumber(key))])
    error_message = "One or more keys in var.interfaces is outside of the allocated interface range."
  }
  validation {
    # Checks to make sure the internal address is a properly formated IP == 192.168.0.1
    condition     = alltrue([for interface in var.interfaces : can(cidrhost("${interface.internalAddress}/32", 0)) || interface.internalAddress == null])
    error_message = "One or more internalAddresses in var.interfaces is not properly formatted. Expected format is a specific IP Addresses or null."
  }
  validation {
    # Checks to make sure the internal address is a properly formated IP == 192.168.0.1
    condition     = alltrue([for interface in var.interfaces : can(cidrhost("${interface.loadbalancerAddress}/32", 0)) || interface.loadbalancerAddress == null])
    error_message = "One or more loadbalancerAddresses in var.interfaces is not properly formatted. Expected format is a specific IP Addresses or null."
  }
  validation {
    # Checks to make sure destinationRanges in sattic routes are properly formated, expecation i
    condition     = alltrue(flatten([for interface in var.interfaces : [for staticRoute in interface.staticRoutes : can(cidrsubnet(staticRoute.destinationRange, 0, 0))]]))
    error_message = "One or more staticRoutes destinationRanges in var.interfaces is not properly formatted. Expected format for destinationRange ip_addr/mask."
  }
}

variable "deletion_protection" {
  type    = bool
  default = false
}
variable "tags" {
  type    = list(string)
  default = []
}

variable "machine_type" {
  type    = string
  default = "e2-standard-8"
}

variable "scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
  ]
}

variable "image" {
  // Hourly Licenses
  default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle1-909"
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle2-909"

  // BYOL License  
  # default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-byol-909"
}