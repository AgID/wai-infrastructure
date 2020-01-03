output "cluster-num-instances" {
  description = "Number of cluster nodes instances"
  value       = lookup(var.cluster_instance, "num_instances", 0)
}

output "cluster-instances" {
  description = "Instances in the cluster"
  value       = openstack_compute_instance_v2.cluster_instance.*.name
}

output "out_subnet_id" {
  description = "Subnet id"
  value = length(openstack_networking_subnet_v2.cluster_subnet) > 0 ? openstack_networking_subnet_v2.cluster_subnet.0.id : ""
}

output "out_members_access_ip_v4" {
  description = "Cluster addresses"
  value = openstack_compute_instance_v2.cluster_instance.*.access_ip_v4
}

output "out_security_group_ids" {
  description = "Cluster security group ids"
  value = openstack_networking_secgroup_v2.cluster_secgroup.*.id
}
