output "cluster-num-instances" {
  description = "Number of cluster nodes instances"
  value       = lookup(var.cluster_instance, "num_instances", 0)
}

output "cluster-instances" {
  description = "Instances in the cluster"
  value       = openstack_compute_instance_v2.cluster_instance.*.name
}
