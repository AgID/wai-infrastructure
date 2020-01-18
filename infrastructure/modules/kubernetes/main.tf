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

# Kubernetes cluser network
resource "openstack_networking_network_v2" "k8s_network" {
  count       = var.enabled ? 1 : 0
  description = "K8S network"
  name        = local.k8s_network_name
}

# Kubernetes subnet
resource "openstack_networking_subnet_v2" "k8s_subnet" {
  count           = var.enabled ? 1 : 0
  description     = "K8S subnet"
  name            = local.k8s_subnet_name
  network_id      = openstack_networking_network_v2.k8s_network[0].id
  cidr            = var.k8s_network_cidr
  dns_nameservers = var.public_dns_ips
}

# Router interface configuration
resource "openstack_networking_router_interface_v2" "k8s_router_interface" {
  count     = var.enabled ? 1 : 0
  router_id = data.openstack_networking_router_v2.main_router[0].id
  subnet_id = openstack_networking_subnet_v2.k8s_subnet[0].id
}

# Kubernetes master security group
resource "openstack_networking_secgroup_v2" "k8s_master_secgroup" {
  count       = var.enabled ? 1 : 0
  name        = local.k8s_master_security_group_name
  description = "K8S master node security group"
}

# Kubernetes worker security group rules
resource "openstack_networking_secgroup_rule_v2" "k8s_master_secgroup_rule" {
  count             = var.enabled ? length(var.k8s_master_sec_rules) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = var.k8s_master_sec_rules[count.index]["protocol"]
  port_range_min    = var.k8s_master_sec_rules[count.index]["from"]
  port_range_max    = var.k8s_master_sec_rules[count.index]["to"]
  remote_ip_prefix  = var.k8s_master_sec_rules[count.index]["cidr"]
  security_group_id = openstack_networking_secgroup_v2.k8s_master_secgroup[0].id
}

# Kubernetes worker security group
resource "openstack_networking_secgroup_v2" "k8s_worker_secgroup" {
  count       = var.enabled ? 1 : 0
  name        = local.k8s_worker_security_group_name
  description = "K8S worker node security group"
}

# Kubernetes worker security group rules
resource "openstack_networking_secgroup_rule_v2" "k8s_worker_secgroup_rule" {
  count             = var.enabled ? length(var.k8s_worker_sec_rules) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = var.k8s_worker_sec_rules[count.index]["protocol"]
  port_range_min    = var.k8s_worker_sec_rules[count.index]["from"]
  port_range_max    = var.k8s_worker_sec_rules[count.index]["to"]
  remote_ip_prefix  = var.k8s_worker_sec_rules[count.index]["cidr"]
  security_group_id = openstack_networking_secgroup_v2.k8s_worker_secgroup[0].id
}

# Kubernetes MetalLB port security group
resource "openstack_networking_secgroup_v2" "k8s_metallb_ports_secgroup" {
  count       = var.enabled ? 1 : 0
  name        = local.k8s_metallb_ports_group_name
  description = "K8S MetalLB port security group"
}

# Kubernetes MetalLB port security group rules
resource "openstack_networking_secgroup_rule_v2" "k8s_metallb_ports_secgroup_rule" {
  count             = var.enabled ? length(var.k8s_metallb_port_sec_rules) : 0
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = var.k8s_metallb_port_sec_rules[count.index]["protocol"]
  port_range_min    = var.k8s_metallb_port_sec_rules[count.index]["from"]
  port_range_max    = var.k8s_metallb_port_sec_rules[count.index]["to"]
  remote_ip_prefix  = var.k8s_metallb_port_sec_rules[count.index]["cidr"]
  security_group_id = openstack_networking_secgroup_v2.k8s_metallb_ports_secgroup[0].id
}

# Kubernetes master node boot volume
resource "openstack_blockstorage_volume_v3" "k8s_master_boot_volume" {
  count       = var.enabled ? lookup(var.k8s_master_instance, "num_instances", 0) : 0
  name        = format("%s-boot-volume-%02d", local.k8s_master_node_name, count.index + 1)
  image_id    = var.k8s_master_instance["image_id"]
  size        = var.k8s_master_instance["boot_volume_size"]
  volume_type = var.k8s_master_instance["boot_volume_type"]
}

# Kubernetes master node instance
resource "openstack_compute_instance_v2" "k8s_master_instance" {
  count     = var.enabled ? lookup(var.k8s_master_instance, "num_instances", 0) : 0
  name      = format("%s-%02d", local.k8s_master_node_name, count.index + 1)
  flavor_id = var.k8s_master_instance["flavor_id"]
  key_pair  = data.openstack_compute_keypair_v2.ssh_keypair[0].name
  user_data = file("cloud-init.conf")
  network {
    port = element(
      openstack_networking_port_v2.k8s_master_port.*.id,
      count.index,
    )
  }
  block_device {
    boot_index      = 0
    uuid            = element(openstack_blockstorage_volume_v3.k8s_master_boot_volume.*.id, count.index)
    source_type      = "volume"
    destination_type = "volume"
  }
  metadata = {
    ansible_user = var.ssh_user
    groups       = join(", ", ["wai", element(var.k8s_master_instance_groups, count.index)])
  }
}

# Kubernetes master node networking port
resource "openstack_networking_port_v2" "k8s_master_port" {
  count = var.enabled ? lookup(var.k8s_master_instance, "num_instances", 0) : 0
  description = format(
    "%s-%02d networking port",
    local.k8s_master_node_name,
    count.index + 1,
  )
  name               = format("%s-%02d", local.k8s_master_port_name, count.index + 1)
  network_id         = openstack_networking_network_v2.k8s_network[0].id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.k8s_master_secgroup[0].id]
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.k8s_subnet[0].id
    ip_address = cidrhost(var.k8s_network_cidr, count.index + 101)
  }
}

# Kubernetes master node floating IP association
resource "openstack_compute_floatingip_associate_v2" "k8s_master_floatingip_association" {
  count       = var.enabled ? min(length(var.k8s_master_floatingips), lookup(var.k8s_master_instance, "num_instances", 0)) : 0
  floating_ip = var.k8s_master_floatingips[count.index]
  instance_id = element(
    openstack_compute_instance_v2.k8s_master_instance.*.id,
    count.index,
  )
}

# Kubernetes master node data volume
resource "openstack_blockstorage_volume_v3" "k8s_master_data_volume" {
  count       = var.enabled ? lookup(var.k8s_master_instance, "num_instances", 0) : 0
  name        = format("%s-data-volume-%02d", local.k8s_master_node_name, count.index + 1)
  size        = var.k8s_master_instance["data_volume_size"]
  volume_type = var.k8s_master_instance["data_volume_type"]
  metadata    = {
    data_storage = true
    attached_mode = "rw"
  }
}

# Kubernetes master node data volume attach
resource "openstack_compute_volume_attach_v2" "k8s_master_data_volume_attach" {
  count = var.enabled ? lookup(var.k8s_master_instance, "num_instances", 0) : 0
  volume_id = element(
    openstack_blockstorage_volume_v3.k8s_master_data_volume.*.id,
    count.index,
  )
  instance_id = element(
    openstack_compute_instance_v2.k8s_master_instance.*.id,
    count.index,
  )
}

# Kubernetes worker node boot volume
resource "openstack_blockstorage_volume_v3" "k8s_worker_boot_volume" {
  count       = var.enabled ? lookup(var.k8s_worker_instance, "num_instances", 0) : 0
  name        = format("%s-boot-volume-%02d", local.k8s_worker_node_name, count.index + 1)
  image_id    = var.k8s_worker_instance["image_id"]
  size        = var.k8s_worker_instance["boot_volume_size"]
  volume_type = var.k8s_worker_instance["boot_volume_type"]
}

# Kubernetes server group
resource "openstack_compute_servergroup_v2" "k8s_server_group" {
  name = "kubernetes-server-group"
  policies = ["anti-affinity"]
}

# Kubernetes worker node instance
resource "openstack_compute_instance_v2" "k8s_worker_instance" {
  count     = var.enabled ? lookup(var.k8s_worker_instance, "num_instances", 0) : 0
  name      = format("%s-%02d", local.k8s_worker_node_name, count.index + 1)
  flavor_id = var.k8s_worker_instance["flavor_id"]
  key_pair  = data.openstack_compute_keypair_v2.ssh_keypair[0].name
  user_data = file("cloud-init.conf")
  network {
    port = element(
      openstack_networking_port_v2.k8s_worker_port.*.id,
      count.index,
    )
  }
  block_device {
    boot_index       = 0
    uuid             = element(openstack_blockstorage_volume_v3.k8s_worker_boot_volume.*.id, count.index)
    source_type      = "volume"
    destination_type = "volume"
  }
  metadata = {
    ansible_user = var.ssh_user
    groups       = join(", ", ["wai", element(var.k8s_worker_instance_groups, count.index)])
  }
  scheduler_hints  {
    group = openstack_compute_servergroup_v2.k8s_server_group.id
  }
}

# Kubernetes MetalLB ports
resource "openstack_networking_port_v2" "k8s_metallb_ports" {
  count = var.enabled ? length(var.k8s_metallb_address_pairs) : 0
  name               = format("k8s-metallb-port-%s", var.k8s_metallb_address_pairs[count.index].ip)
  network_id         = openstack_networking_network_v2.k8s_network[0].id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.k8s_metallb_ports_secgroup[0].id]
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.k8s_subnet[0].id
    ip_address = var.k8s_metallb_address_pairs[count.index].ip
  }
}

# Kubernetes floating IP association for MetalLB address
resource "openstack_networking_floatingip_associate_v2" "k8s_metallb_address_floatingip_association" {
  count       = var.enabled ? min(length(openstack_networking_port_v2.k8s_metallb_ports), length(var.k8s_metallb_address_pairs)) : 0
  floating_ip = var.k8s_metallb_address_pairs[count.index].floating_ip
  port_id     = element(
    openstack_networking_port_v2.k8s_metallb_ports.*.id,
    count.index,
  )
}

# Kubernetes worker node networking port
resource "openstack_networking_port_v2" "k8s_worker_port" {
  count = var.enabled ? lookup(var.k8s_worker_instance, "num_instances", 0) : 0
  description = format(
    "%s-%02d networking port",
    local.k8s_worker_node_name,
    count.index + 1,
  )
  name               = format("%s-%02d", local.k8s_worker_port_name, count.index + 1)
  network_id         = openstack_networking_network_v2.k8s_network[0].id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.k8s_worker_secgroup[0].id]
  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.k8s_subnet[0].id
    ip_address = cidrhost(var.k8s_network_cidr, count.index + 151)
  }
  dynamic "allowed_address_pairs" {
    for_each = var.k8s_metallb_address_pairs
    content {
      ip_address = allowed_address_pairs.value.ip
    }
  }  
}

# Kubernetes worker node floating IP association
resource "openstack_compute_floatingip_associate_v2" "k8s_worker_floatingip_association" {
  count       = var.enabled ? min(length(var.k8s_worker_floatingips), lookup(var.k8s_worker_instance, "num_instances", 0)) : 0
  floating_ip = var.k8s_worker_floatingips[count.index]
  instance_id = element(
    openstack_compute_instance_v2.k8s_worker_instance.*.id,
    count.index,
  )
}

# Kubernetes worker node data volume
resource "openstack_blockstorage_volume_v3" "k8s_worker_data_volume" {
  count       = var.enabled ? lookup(var.k8s_worker_instance, "num_instances", 0) : 0
  name        = format("%s-data-volume-%02d", local.k8s_worker_node_name, count.index + 1)
  size        = var.k8s_worker_instance["data_volume_size"]
  volume_type = var.k8s_worker_instance["data_volume_type"]
  metadata    = {
    data_storage = true
    attached_mode = "rw"
  }
}

# Kubernetes worker node volume attach
resource "openstack_compute_volume_attach_v2" "k8s_worker_data_volume_attach" {
  count = var.enabled ? lookup(var.k8s_worker_instance, "num_instances", 0) : 0
  volume_id = element(
    openstack_blockstorage_volume_v3.k8s_worker_data_volume.*.id,
    count.index,
  )
  instance_id = element(
    openstack_compute_instance_v2.k8s_worker_instance.*.id,
    count.index,
  )
}
