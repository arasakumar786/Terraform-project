
#aws ssm put-parameter --name "/rds/dev-mysql/master_password" --type SecureString --value "MyStrongPassword123@" --overwrite

data "aws_ssm_parameter" "rds_password" {
  name            = "/rds/${var.rds_identifier}/master_password"
  with_decryption = true
}

resource "aws_db_instance" "mysql" {
  identifier = var.rds_identifier

  engine         = "mysql"
  engine_version = var.rds_engine_version

  instance_class = var.rds_instance_class

  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp2"

  username = var.rds_master_username
  password = data.aws_ssm_parameter.rds_password.value
  db_subnet_group_name = aws_db_subnet_group.mysql.name
  db_name = var.rds_database_name

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 7

  skip_final_snapshot = true
  deletion_protection = false

  auto_minor_version_upgrade = true
  tags = {
    Name = var.rds_identifier
  }
}
resource "aws_db_subnet_group" "mysql" {
  name = "${var.rds_identifier}-subnet-group"

  subnet_ids = [
    var.private_subnet_ids[0],
    var.private_subnet_ids[1]
  ]
}



