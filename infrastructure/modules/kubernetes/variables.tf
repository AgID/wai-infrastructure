# States if this module is enabled in the current workspace
variable "enabled" {
  type        = string
  description = "States if this module is enabled in the current workspace"
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

# K8S network CIDR
variable "k8s_network_cidr" {
  type        = string
  description = "Kubernetes network CIDR"
}

# K8S master instance parameters
variable "k8s_master_instance" {
  type        = map(string)
  description = "Kubernetes master instance parameters"
}

# K8S master instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "k8s_master_instance_groups" {
  type        = list(string)
  description = "Groups in kubernetes master instances metadata"
}

# K8S master security rules
variable "k8s_master_sec_rules" {
  type        = list
  description = "Kubernetes master security rules"
}

# K8S master assigned floating IPs
variable "k8s_master_floatingips" {
  type        = list(string)
  description = "Kubernetes master assigned floating IP addresses"
}

# K8S worker instance parameters
variable "k8s_worker_instance" {
  type        = map(string)
  description = "Kubernetes worker instance parameters"
}

# K8S worker instance groups added to metadata for ansible dynamic inventory
variable "k8s_worker_instance_groups" {
  type        = list(string)
  description = "Groups in kubernetes worker instances metadata"
}

# K8S worker security rules
variable "k8s_worker_sec_rules" {
  type        = list
  description = "Kubernetes worker security rules"
}

# K8S worker assigned floating IPs
variable "k8s_worker_floatingips" {
  type        = list(string)
  description = "Kubernetes worker assigned floating IP addresses"
}

# K8S worker assigned floating IPs
variable "k8s_worker_load_balancers" {
  type      = list(string)
  default = ["production", "public-playground", "staging"]
}

locals {
  # Define resource names based on the following convention:
  # {project_name_prefix}-RESOURCE_TYPE
  k8s_master_security_group_name = "${var.project_name_prefix}-k8s-master-sg"
  k8s_worker_security_group_name = "${var.project_name_prefix}-k8s-worker-sg"
  k8s_router_name                = "${var.project_name_prefix}-k8s-router"
  k8s_network_name               = "${var.project_name_prefix}-k8s-network"
  k8s_subnet_name                = "${var.project_name_prefix}-k8s-subnet"
  k8s_master_node_name           = "${var.project_name_prefix}-k8s-master"
  k8s_master_port_name           = "${var.project_name_prefix}-k8s-master-port"
  k8s_worker_node_name           = "${var.project_name_prefix}-k8s-worker"
  k8s_worker_port_name           = "${var.project_name_prefix}-k8s-worker-port"
}
