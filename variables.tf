
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

variable "bootstrap_files_staged" {
  type = bool
}
variable "ssh_key" {
  type = string
}
variable "block_project_ssh_keys" {
  type    = bool
  default = true
}
variable "mgmt_interface_swap" {
  type    = string
  default = "enable"
}

variable "interfaces" {
  type = map(object({
      network = string,
      subnetwork = string,
      internalAddress = string,
      externalEnabled = bool,
    })
  )
  validation {
    # Checks to see if any of the keys in the interface map are non-numbers
    condition = (      
      !(can(index([for key in keys(var.interfaces): can(tonumber(key)) ], false)))
    )
    error_message = "One or more keys in var.interfaces is not a number."
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
    "https://www.googleapis.com/auth/cloud-platform",
  ]
}

variable "image" {
  default = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-bundle1-909"
}