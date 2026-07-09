output "cluster_name" {
  value = aws_eks_cluster.trend_store_production.name
}

output "cluster_arn" {
  value = aws_eks_cluster.trend_store_production.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.trend_store_production.endpoint
}

output "cluster_version" {
  value = aws_eks_cluster.trend_store_production.version
}

output "cluster_certificate_authority" {
  value     = aws_eks_cluster.trend_store_production.certificate_authority[0].data
  sensitive = true
}

output "node_group_name" {
  value = aws_eks_node_group.trend_store_production.node_group_name
}