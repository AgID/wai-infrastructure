resource "openstack_lb_loadbalancer_v2" "load_balancer" {
  count = var.enabled ? 1 : 0
  name = var.lb_name
  vip_subnet_id = var.lb_subnet_id
  security_group_ids = var.lb_security_group_ids
}

resource "openstack_lb_listener_v2" "load_balancer_listener" {
  count = var.enabled && length(var.lb_ports) > 0 ? length(var.lb_ports) : 0
  protocol        = "TCP"
  protocol_port   = var.lb_ports[count.index]["src"]
  name = format("%s-lsnr-%d", var.lb_name, var.lb_ports[count.index]["src"])
  loadbalancer_id = openstack_lb_loadbalancer_v2.load_balancer[0].id
}

resource "openstack_lb_pool_v2" "load_balancer_pool" {
  count = var.enabled && length(var.lb_ports) > 0 ? length(var.lb_ports) : 0
  name = format("%s-pool-%d", var.lb_name, var.lb_ports[count.index]["src"])
  protocol    = "TCP"
  lb_method   = "SOURCE_IP"
  listener_id = openstack_lb_listener_v2.load_balancer_listener[count.index].id
  admin_state_up = true
}

resource "openstack_lb_monitor_v2" "load_balancer_monitor" {
  count = var.enabled && length(var.lb_ports) > 0 ? length(var.lb_ports) : 0
  name = format("%s-mon-%d", var.lb_name, var.lb_ports[count.index]["dst"])
  pool_id = openstack_lb_pool_v2.load_balancer_pool[count.index].id
  type = "TCP"
  delay = 30
  timeout = 10
  max_retries = 5
  admin_state_up = true
}

resource "openstack_lb_member_v2" "load_balancer_members" {
  count = var.enabled && length(var.lb_ports) > 0 ? length(var.lb_ports) * length(var.lb_members) : 0
  pool_id = openstack_lb_pool_v2.load_balancer_pool[ count.index  % length(var.lb_ports) ].id
  address = var.lb_members[count.index  % length(var.lb_members)]
  subnet_id = var.lb_subnet_id
  protocol_port = var.lb_ports[ count.index  % length(var.lb_ports) ]["dst"]
  admin_state_up = true
}


