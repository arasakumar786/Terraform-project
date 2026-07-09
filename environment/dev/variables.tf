variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "availability_zone_1" {
  description = "The first availability zone"
  type        = string
}
variable "availability_zone_2" {
  description = "The second availability zone"
  type        = string
}

variable "public_subnet_1_cidr" {
  type = string
}

variable "public_subnet_2_cidr" {
  type = string
}
variable "private_subnet_1_cidr" {
  description = "The CIDR block for the first private subnet"
  type        = string
}
variable "private_subnet_2_cidr" {
  description = "The CIDR block for the second private subnet"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}
variable "aws_region" {
  description = "The AWS region"
  type        = string
}
variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
}
variable "eks_instance_types" {
  description = "The instance types for the EKS nodes"
  type        = list(string)
}
variable "desired_size" {
  description = "The desired size of the EKS node group"
  type        = number
}
variable "min_size" {
  description = "The minimum size of the EKS node group"
  type        = number
}
variable "max_size" {
  description = "The maximum size of the EKS node group"
  type        = number
}
variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}
variable "instance_type" {
  description = "The instance type for the EC2 instance"
  type        = string
}
variable "rds_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}
variable "rds_master_username" {
  description = "The master username for the RDS instance"
  type        = string
}
variable "rds_database_name" {
  description = "The name of the database for the RDS instance"
  type        = string
}
variable "rds_engine_version" {
  description = "The engine version for the RDS instance"
  type        = string
}
variable "rds_instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "rds_db_password" {
  description = "The password for the RDS database"
  type        = string
  sensitive   = true
}