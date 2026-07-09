variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Version"
  type        = string
  default     = "1.31"
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS"
  type        = list(string)
}

variable "cluster_role_arn" {
  description = "EKS Cluster IAM Role ARN"
  type        = string
}

variable "node_role_arn" {
  description = "EKS Node Group IAM Role ARN"
  type        = string
}

variable "security_group_id" {
  description = "EKS Security Group ID"
  type        = string
}

variable "instance_types" {
  description = "Worker node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}
variable "region" {
  description = "AWS Region"
  type        = string
}