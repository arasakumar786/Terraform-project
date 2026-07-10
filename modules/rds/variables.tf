variable "rds_identifier" {
  type = string
}

variable "rds_master_username" {
  type = string
}

variable "rds_database_name" {
  type = string
}

variable "rds_engine_version" {
  type    = string
  default = "8.0.39"
}

variable "rds_instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "private_subnet_ids" {
  type = list(string)
}