
#aws ssm put-parameter --name "/rds/dev-mysql/master_password" --type SecureString --value "MyStrongPassword123@" --overwrite

data "aws_ssm_parameter" "db_password" {
  name            = "/rds/${var.identifier}/master_password"
  with_decryption = true
}

resource "aws_db_instance" "mysql" {
  identifier = var.identifier

  engine         = "mysql"
  engine_version = var.engine_version

  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp2"

  username = var.master_username
  password = data.aws_ssm_parameter.db_password.value

  db_name = var.database_name

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 7

  skip_final_snapshot = true
  deletion_protection = false

  auto_minor_version_upgrade = true

  tags = {
    Name = var.identifier
  }
}



