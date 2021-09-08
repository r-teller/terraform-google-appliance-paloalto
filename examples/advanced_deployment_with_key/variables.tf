variable "project_id" {
  type = string
}

variable "networks" {
  type = list(string)
}

variable "ssh_key" {
  type    = string
  default = ""
}