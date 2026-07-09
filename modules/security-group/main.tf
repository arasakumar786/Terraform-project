resource "aws_security_group" "public_sg" {
  name        = "${var.environment}-public_sg"
  description = "Security group for public access"
  vpc_id      =  var.vpc_id

  ingress {
    description = "Allow all TCP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-public_sg"
  }
}