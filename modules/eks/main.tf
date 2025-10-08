# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "acme-eks"
  role_arn = var.cluster_role_arn
  version  = "1.28"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.cluster_security_group]
  }
}

# EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "acme-nodes"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }
}