output "vpc_id" {
  value = module.vpc.vpc_id
}
output "subnet_ids" {
  value = module.vpc.subnet_ids
}
output "security_group_id" {
  value = module.security_group.security_group_id
}
output "eks_cluster_name" {
  value = module.eks.cluster_name
}
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "eks_node_group_name" {
  value = module.eks.node_group_name
}
output "ec2_instance_id" {
  value = module.ec2.instance_id
}
output "ec2_public_ip" {
  value = module.ec2.public_ip
}