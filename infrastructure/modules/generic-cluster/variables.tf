# States if this module is enabled in the current workspace
variable "enabled" {
  type        = string
  description = "States if this module is enabled in the current workspace"
}

# Environment short name
variable "environment_short" {
  type        = string
  description = "Short version of environment name: prod, stag or play (used in resource names)"
}

# Global project prefix
variable "project_name_prefix" {
  type        = string
  description = "Global project prefix"
}

# Main router name
variable "main_router_name" {
  type        = string
  description = "Main router name"
}

# DNS servers added to all instances
variable "public_dns_ips" {
  type        = list(string)
  description = "DNS servers added to all instances"
}

# SSH public key authorized in all instances
variable "ssh_keypair_name" {
  type        = string
  description = "SSH public key authorized in all instances"
}

# SSH user added to instances metadata for ansible dynamic inventory
variable "ssh_user" {
  type        = string
  description = "SSH user added to instances metadata for ansible dynamic inventory"
}

# Cluster slug name
variable "cluster_slug" {
  type        = string
  description = "Cluster slug name"
}

# Cluster network CIDR
variable "cluster_network_cidr" {
  type        = string
  description = "Cluster network CIDR"
}

# Cluster instance flavor
variable "cluster_flavor" {
  type        = map(string)
  description = "Cluster instance flavor"
}

# Cluster instance parameters
variable "cluster_instance" {
  type        = map(string)
  description = "Cluster instance parameters"
}

# Cluster instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "cluster_instance_groups" {
  type        = list(string)
  description = "Groups in cluster instances metadata"
}

# Cluster security rules
variable "cluster_sec_rules" {
  type        = list
  description = "Cluster security rules"
}

locals {
  # Define resource names based on the following convention:
  # {project_name_prefix}-RESOURCE_TYPE[-{environment_short}]
  cluster_security_group_name = "${var.project_name_prefix}-${var.cluster_slug}-sg-${var.environment_short}"
  cluster_router_name         = "${var.project_name_prefix}-${var.cluster_slug}-router-${var.environment_short}"
  cluster_network_name        = "${var.project_name_prefix}-${var.cluster_slug}-network-${var.environment_short}"
  cluster_subnet_name         = "${var.project_name_prefix}-${var.cluster_slug}-subnet-${var.environment_short}"
  cluster_flavor_name         = "${var.project_name_prefix}-${var.cluster_slug}-flavor-${var.environment_short}"
  cluster_node_name           = "${var.project_name_prefix}-${var.cluster_slug}-${var.environment_short}"
  cluster_port_name           = "${var.project_name_prefix}-${var.cluster_slug}-port-${var.environment_short}"
  cluster_volume_name         = "${var.project_name_prefix}-${var.cluster_slug}-volume-${var.environment_short}"
}
