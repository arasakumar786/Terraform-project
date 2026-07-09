output "security_group_id" {
  value = aws_security_group.public_sg.id
}
output "security_group_arn" {
  value = aws_security_group.public_sg.arn
}