variable "cidr_block" {
    description = "The CIDR block for the VPC."
    type        = string    
}

variable "public_subnet_1_cidr_block" {
    description = "The CIDR block for the first public subnet."
    type        = string
}

variable "public_subnet_2_cidr_block" {
    description = "The CIDR block for the second public subnet."
    type        = string
}

variable "private_subnet_1_cidr_block" {
    description = "The CIDR block for the first private subnet."
    type        = string
}
variable "private_subnet_2_cidr_block" {
    description = "The CIDR block for the second private subnet."
    type        = string
}
variable "environment" {
    description = "The environment name."
    type        = string
}
variable "availability_zone_1" {
    description = "The availability zone for the first public subnet."
    type        = string
}
variable "availability_zone_2" {
    description = "The availability zone for the second public subnet."
    type        = string
}
variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}


