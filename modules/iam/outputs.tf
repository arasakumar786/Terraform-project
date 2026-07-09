
output "cluster_role_arn" {
  description = "ARN of the EKS Cluster Role"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "cluster_role_name" {
  description = "Name of the EKS Cluster Role"
  value       = aws_iam_role.eks_cluster_role.name
}

output "node_role_arn" {
  description = "ARN of the EKS Node Group Role"
  value       = aws_iam_role.node_role.arn
}

output "node_role_name" {
  description = "Name of the EKS Node Group Role"
  value       = aws_iam_role.node_role.name
}