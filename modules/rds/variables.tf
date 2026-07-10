variable "identifier" {
  type = string
}

variable "master_username" {
  type = string
}

variable "database_name" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "8.0.39"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "private_subnet_ids" {
  type = list(string)
}