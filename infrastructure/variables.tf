# Environment
variable environment {
  type = "string"
  description = "Environment: production, staging or public-playground"
}

# Environment short name
variable environment_short {
  type = "string"
  description = "Short version of environment name: prod, stag or play (used in resource names)"
}

# Global project prefix
variable "project_name_prefix" {
  type = "string"
  description = "# Global project prefix"
}

# Public network ID
variable "spccloud_public_network_id" {
  type = "string"
  description = "Public network ID"
}

# DNS servers added to all instances
variable "public_dns_ips" {
  type = "list"
  description = "DNS servers added to all instances"
}

# SSH public key authorized in all instances
variable "keypair_pubkey" {
  type = "string"
  description = "SSH public key authorized in all instances"
}

# SSH user added to instances metadata for ansible dynamic inventory
variable "ssh_user" {
  type = "string"
  description = "SSH user added to instances metadata for ansible dynamic inventory"
}

# K8S network CIDR
variable "k8s_network_cidr" {
  type = "string"
  description = "Kubernetes network CIDR"
  default = ""
}

# K8S master instance flavor
variable "k8s_master_flavor" {
  type = "map"
  description = "Kubernetes master instance flavor"
  default = {}
}

# K8S master instance parameters
variable "k8s_master_instance" {
  type = "map"
  description = "Kubernetes master instance parameters"
  default = {}
}

# K8S master instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "k8s_master_instance_groups" {
  type = "list"
  description = "Groups in kubernetes master instances metadata"
  default = []
}

# K8S master security rules
variable "k8s_master_sec_rules" {
  type = "list"
  description = "Kubernetes master security rules"
  default = []
}

# K8S master assigned floating IPs
variable "k8s_master_floatingips" {
  type = "list"
  description = "Kubernetes master assigned floating IP addresses"
  default = []
}

# K8S worker instance flavor
variable "k8s_worker_flavor" {
  type = "map"
  description = "Kubernetes worker instance flavor"
  default = {}
}

# K8S worker instance parameters
variable "k8s_worker_instance" {
  type = "map"
  description = "Kubernetes worker instance parameters"
  default = {}
}

# K8S worker instance groups added to metadata for ansible dynamic inventory
variable "k8s_worker_instance_groups" {
  type = "list"
  description = "Groups in kubernetes worker instances metadata"
  default = []
}

# K8S worker security rules
variable "k8s_worker_sec_rules" {
  type = "list"
  description = "Kubernetes worker security rules"
  default = []
}

# K8S worker assigned floating IPs
variable "k8s_worker_floatingips" {
  type = "list"
  description = "Kubernetes worker assigned floating IP addresses"
  default = []
}

# Galera slug name
variable "galera_slug" {
  type = "string"
  description = "Galera slug name"
  default = ""
}

# Galera network CIDR
variable "galera_network_cidr" {
  type = "string"
  description = "Galera network CIDR"
  default = ""
}

# Galera instance flavor
variable "galera_flavor" {
  type = "map"
  description = "Galera instance flavor"
  default = {}
}

# Galera instance parameters
variable "galera_instance" {
  type = "map"
  description = "Galera instance parameters"
  default = {}
}

# Galera instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "galera_instance_groups" {
  type = "list"
  description = "Groups in galera instances metadata"
  default = []
}

# Galera security rules
variable "galera_sec_rules" {
  type = "list"
  description = "Galera security rules"
  default = []
}

# MariaDB slug name
variable "mariadb_slug" {
  type = "string"
  description = "MariaDB slug name"
  default = ""
}

# MariaDB network CIDR
variable "mariadb_network_cidr" {
  type = "string"
  description = "MariaDB network CIDR"
  default = ""
}

# MariaDB instance flavor
variable "mariadb_flavor" {
  type = "map"
  description = "MariaDB instance flavor"
  default = {}
}

# MariaDB instance parameters
variable "mariadb_instance" {
  type = "map"
  description = "MariaDB instance parameters"
  default = {}
}

# MariaDB instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "mariadb_instance_groups" {
  type = "list"
  description = "Groups in mariaDB instances metadata"
  default = []
}

# MariaDB security rules
variable "mariadb_sec_rules" {
  type = "list"
  description = "MariaDB security rules"
  default = []
}

# Elastic slug name
variable "elastic_slug" {
  type = "string"
  description = "Elastic slug name"
  default = ""
}

# Elastic network CIDR
variable "elastic_network_cidr" {
  type = "string"
  description = "Elastic network CIDR"
  default = ""
}

# Elastic instance flavor
variable "elastic_flavor" {
  type = "map"
  description = "Elastic instance flavor"
  default = {}
}

# Elastic instance parameters
variable "elastic_instance" {
  type = "map"
  description = "Elastic instance parameters"
  default = {}
}

# Elastic instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "elastic_instance_groups" {
  type = "list"
  description = "Groups in elastic instances metadata"
  default = []
}

# Elastic security rules
variable "elastic_sec_rules" {
  type = "list"
  description = "Elastic security rules"
  default = []
}

# Gluster slug name
variable "gluster_slug" {
  type = "string"
  description = "Gluster slug name"
  default = ""
}

# Gluster network CIDR
variable "gluster_network_cidr" {
  type = "string"
  description = "Gluster network CIDR"
  default = ""
}

# Gluster instance flavor
variable "gluster_flavor" {
  type = "map"
  description = "Gluster instance flavor"
  default = {}
}

# Gluster instance parameters
variable "gluster_instance" {
  type = "map"
  description = "Gluster instance parameters"
  default = {}
}

# Gluster instance groups added to metadata for ansible dynamic inventory
# Each item in the list will be added to the corresponding instance number
# i.e. the first item in the list will be added to the first instance and so on
# if there are more instances than items in the list it will restart from the first one
variable "gluster_instance_groups" {
  type = "list"
  description = "Groups in gluster instances metadata"
  default = []
}

# Gluster security rules
variable "gluster_sec_rules" {
  type = "list"
  description = "Gluster security rules"
  default = []
}

locals {
  # Define resource names based on the following convention:
  # {project_name_prefix}-RESOURCE_TYPE
  keypair_pubkey_name = "${var.project_name_prefix}-keypair"
  main_router_name = "${var.project_name_prefix}-router"
}