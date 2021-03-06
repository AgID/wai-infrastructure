output "k8s-worker-num-instances" {
  description = "Number of K8S worker nodes instances"
  value       = lookup(var.k8s_worker_instance, "num_instances", 0)
}

output "k8s-master-instances" {
  description = "K8S master node instances"
  value       = openstack_compute_instance_v2.k8s_master_instance.*.name
}

output "k8s-worker-public-ips" {
  description = "Public IPs associated with K8S worker nodes"
  value       = openstack_compute_floatingip_associate_v2.k8s_worker_floatingip_association.*.floating_ip
}

output "k8s-master-num-instances" {
  description = "Number of K8S master nodes instances"
  value       = lookup(var.k8s_master_instance, "num_instances", 0)
}

output "k8s-master-public-ips" {
  description = "Public IPs associated with K8S master/etcd nodes"
  value       = openstack_compute_floatingip_associate_v2.k8s_master_floatingip_association.*.floating_ip
}

output "out_subnet_id" {
  description = "Subnet id"
  value       = length(openstack_networking_subnet_v2.k8s_subnet) > 0 ? openstack_networking_subnet_v2.k8s_subnet.0.id : ""
}

output "out_members_access_ip_v4" {
  description = "K8S Worker addresses"
  value       = openstack_compute_instance_v2.k8s_worker_instance.*.access_ip_v4
}

output "out_security_group_ids" {
  description = "K8S workers security group ids"
  value       = openstack_networking_secgroup_v2.k8s_worker_secgroup.*.id
}
