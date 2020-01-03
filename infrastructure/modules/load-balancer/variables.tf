# States if this module is enabled in the current workspace
variable "enabled" {
  type        = string
  description = "States if this module is enabled in the current workspace"
}

# Load balancer name
variable "lb_name" {
  type = string
  description = "Load balancer ports"
  default = ""
}

# Load balancer subnet id
variable "lb_subnet_id" {
  type = string
  description = "Subnet id"
  default = ""
}

# Load balanced ports
variable "lb_ports" {
  type = list
  description = "Load balancer ports"
  default = []
}

# Load balanced ports
variable "lb_members" {
  type = list(string)
  description = "Load members ip addresses"
  default = []
}

locals {
}
