# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = ["us-east-1a", "us-east-1b"]
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  azs    = local.azs
}

# NAT Gateway Module  
module "nat_gateway" {
  source               = "./modules/nat_gateway"
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
}

# Security Groups
module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# IAM Roles
module "iam_role" {
  source = "./iam_role"
}

# EKS Cluster
module "eks" {
  source                  = "./modules/eks"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  cluster_role_arn        = module.iam_role.cluster_role_arn
  node_role_arn           = module.iam_role.node_role_arn
  cluster_security_group  = module.security_group.cluster_sg_id
  node_security_group     = module.security_group.node_sg_id
}
