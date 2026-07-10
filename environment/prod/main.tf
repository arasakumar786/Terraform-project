terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

  }
}
module "vpc" {
  source = "../../modules/vpc"

  environment                = var.environment
  cidr_block                 = var.vpc_cidr
  public_subnet_1_cidr_block = var.public_subnet_1_cidr
  public_subnet_2_cidr_block = var.public_subnet_2_cidr

  private_subnet_1_cidr_block = var.private_subnet_1_cidr
  private_subnet_2_cidr_block = var.private_subnet_2_cidr
  availability_zone_1         = var.availability_zone_1
  availability_zone_2         = var.availability_zone_2
  cluster_name                = var.cluster_name
}

module "security-group" {
  source = "../../modules/security-group"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}
module "iam" {
  source = "../../modules/iam"

  environment = var.environment
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  region          = var.aws_region
  subnet_ids = [
    module.vpc.public_subnet_id_1,
    module.vpc.public_subnet_id_2
  ]
  cluster_role_arn = module.iam.cluster_role_arn
  node_role_arn    = module.iam.node_role_arn

  security_group_id = module.security-group.security_group_id

  instance_types = var.eks_instance_types

  desired_size = var.desired_size
  min_size     = var.min_size
}
module "rds" {
  source = "../../modules/rds"

  rds_identifier      = var.rds_identifier
  rds_engine_version  = var.rds_engine_version
  rds_instance_class  = var.rds_instance_class
  rds_master_username = var.rds_master_username
  rds_database_name   = var.rds_database_name
  private_subnet_ids = [
    module.vpc.private_subnet_id_1,
    module.vpc.private_subnet_id_2
  ]
}


