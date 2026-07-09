resource "aws_eks_cluster" "trend_store_production" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]

    endpoint_private_access = true
    endpoint_public_access  = true
  }
}
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.trend_store_production.name
  addon_name   = "vpc-cni"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.trend_store_production
  ]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.trend_store_production.name
  addon_name   = "coredns"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.trend_store_production   # coredns pods need nodes to schedule on
  ]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.trend_store_production.name
  addon_name   = "kube-proxy"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.trend_store_production
  ]
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.trend_store_production.name
  addon_name   = "eks-pod-identity-agent"

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_cluster.trend_store_production
  ]
}
resource "aws_eks_node_group" "trend_store_production" {
  cluster_name    = aws_eks_cluster.trend_store_production.name
  node_group_name = "${var.cluster_name}-nodegroup"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  capacity_type = "SPOT"

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_eks_cluster.trend_store_production
  ]
}

resource "aws_eks_access_entry" "root" {
  cluster_name  = aws_eks_cluster.trend_store_production.name
  principal_arn = "arn:aws:iam::369559608694:root"
}

resource "aws_eks_access_policy_association" "root" {
  cluster_name  = aws_eks_cluster.trend_store_production.name
  principal_arn = aws_eks_access_entry.root.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
