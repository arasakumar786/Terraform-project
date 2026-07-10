output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "rds_port" {
  value = aws_db_instance.mysql.port
}

output "rds_identifier" {
  value = aws_db_instance.mysql.id
}
