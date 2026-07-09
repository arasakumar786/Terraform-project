resource "aws_vpc" "test_vpc" {
  cidr_block           = var.cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.public_subnet_1_cidr_block
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.environment}-public-subnet-1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = var.public_subnet_2_cidr_block
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "${var.environment}-public-subnet-2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.private_subnet_1_cidr_block
  availability_zone = var.availability_zone_1
  tags = {
    Name                                        = "${var.environment}-private-subnet-1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = var.private_subnet_2_cidr_block
  availability_zone = var.availability_zone_2
  tags = {
    Name                                        = "${var.environment}-private-subnet-2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "${var.environment}-test-vpc-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-test-vpc-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "${var.environment}-test-vpc-private-route-table"
  }
}

resource "aws_route_table_association" "private_route_table_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}

