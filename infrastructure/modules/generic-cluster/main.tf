# SSH keypair
data "openstack_compute_keypair_v2" "ssh_keypair" {
  count = var.enabled ? 1 : 0
  name  = var.ssh_keypair_name
}

# Main router
data "openstack_networking_router_v2" "main_router" {
  count       = var.enabled ? 1 : 0
  description = "Infrastructure main router"
  name        = var.main_router_name
}

# Cluster cluser network
resource "openstack_networking_network_v2" "cluster_network" {
  count       = var.enabled ? 1 : 0
  description = "Cluster network"
  name        = local.cluster_network_name
}

# Cluster subnet
resource "openstack_networking_subnet_v2" "cluster_subnet" {
  count           = var.enabled ? 1 : 0
  description     = "Cluster subnet"
  name            = local.cluster_subnet_name
  network_id      = openstack_networking_network_v2.cluster_network[0].id
  cidr            = var.cluster_network_cidr
  dns_nameservers = var.public_dns_ips
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "cluster_router_iterface" {
  count     = var.enabled ? 1 : 0
  router_id = data.openstack_networking_router_v2.main_router[0].id
  subnet_id = openstack_networking_subnet_v2.cluster_subnet[0].id
}

# Cluster security group
resource "openstack_networking_secgroup_v2" "cluster_secgroup" {
  count       = var.enabled ? 1 : 0
  name        = local.cluster_security_group_name
  description = "Cluster node security group"
}

# Cluster security group rules
resource "openstack_networking_secgroup_rule_v2" "cluster_secgroup_rule" {
  count             = var.enabled ? length(var.cluster_sec_rules) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = var.cluster_sec_rules[count.index]["protocol"]
  port_range_min    = var.cluster_sec_rules[count.index]["from"]
  port_range_max    = var.cluster_sec_rules[count.index]["to"]
  remote_ip_prefix  = var.cluster_sec_rules[count.index]["cidr"]
  security_group_id = openstack_networking_secgroup_v2.cluster_secgroup[0].id
}

# Cluster node boot volume
resource "openstack_blockstorage_volume_v3" "cluster_boot_volume" {
  count       = var.enabled ? lookup(var.cluster_instance, "num_instances", 0) : 0
  name        = format("%s-boot-volume-%02d", local.cluster_node_name, count.index + 1)
  image_id    = var.cluster_instance["image_id"]
  size        = var.cluster_instance["boot_volume_size"]
  volume_type = var.cluster_instance["boot_volume_type"]
}

# Cluster server group
resource "openstack_compute_servergroup_v2" "server_group" {
  count    = var.enabled ? 1 : 0
  name     = format("%s-server-group", local.cluster_node_name)
  policies = ["anti-affinity"]
}

# Cluster node instance
resource "openstack_compute_instance_v2" "cluster_instance" {
  count     = var.enabled ? lookup(var.cluster_instance, "num_instances", 0) : 0
  name      = format("%s-%02d", local.cluster_node_name, count.index + 1)
  flavor_id = var.cluster_instance["flavor_id"]
  key_pair  = data.openstack_compute_keypair_v2.ssh_keypair[0].name
  user_data = file("cloud-init.conf")
  network {
    port = element(openstack_networking_port_v2.cluster_port.*.id, count.index)
  }
  block_device {
    boot_index       = 0
    uuid             = element(openstack_blockstorage_volume_v3.cluster_boot_volume.*.id, count.index)
    source_type      = "volume"
    destination_type = "volume"
  }
  metadata = {
    ansible_user = var.ssh_user
    groups       = join(", ", ["wai", element(var.cluster_instance_groups, count.index)])
  }
  scheduler_hints {
    group = openstack_compute_servergroup_v2.server_group.0.id
  }
}

# Cluster node networking port
resource "openstack_networking_port_v2" "cluster_port" {
  count = var.enabled ? lookup(var.cluster_instance, "num_instances", 0) : 0
  description = format(
    "%s-%02d networking port",
    local.cluster_node_name,
    count.index + 1,
  )
  name               = format("%s-%02d", local.cluster_port_name, count.index + 1)
  network_id         = openstack_networking_network_v2.cluster_network[0].id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.cluster_secgroup[0].id]
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.cluster_subnet[0].id
    ip_address = cidrhost(var.cluster_network_cidr, count.index + 101)
  }
}

# Cluster node volume
resource "openstack_blockstorage_volume_v3" "cluster_data_volume" {
  count       = var.enabled ? lookup(var.cluster_instance, "num_instances", 0) : 0
  name        = format("%s-data-volume-%02d", local.cluster_node_name, count.index + 1)
  size        = var.cluster_instance["data_volume_size"]
  volume_type = var.cluster_instance["data_volume_type"]
  metadata = {
    data_storage  = true
    attached_mode = "rw"
  }
}

# Cluster node volume attach
resource "openstack_compute_volume_attach_v2" "cluster_volume_attach" {
  count = var.enabled ? lookup(var.cluster_instance, "num_instances", 0) : 0
  volume_id = element(
    openstack_blockstorage_volume_v3.cluster_data_volume.*.id,
    count.index,
  )
  instance_id = element(openstack_compute_instance_v2.cluster_instance.*.id, count.index)
}
