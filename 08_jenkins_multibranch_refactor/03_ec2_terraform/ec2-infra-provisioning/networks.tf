# VPC
resource "aws_vpc" "lc_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    "Name" = "lc-vpc"
  }
}

# SUBNET
resource "aws_subnet" "lc_pub" {
  vpc_id            = aws_vpc.lc_vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr

  tags = {
    "Name" = "lc-pub"
  }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "lc_igw" {
  vpc_id = aws_vpc.lc_vpc.id

  tags = {
    "Name" = "lc-igw"
  }
}

# ROUTE TABLE 
resource "aws_route_table" "lc_vpc_pub" {
  vpc_id = aws_vpc.lc_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lc_igw.id
  }

  tags = {
    "Name" = "lc-vpc-route"
  }
}

resource "aws_route_table_association" "lc_pub_route" {
  subnet_id      = aws_subnet.lc_pub.id
  route_table_id = aws_route_table.lc_vpc_pub.id
}

# SECURITY GROUPS
resource "aws_security_group" "lc_pub_sg" {
  name        = "lc-pub-sg"
  description = "lc-pub-subnet sg"
  vpc_id      = aws_vpc.lc_vpc.id
}

# TODO: Refactor with for_each?
# Ingress Security Group Rules
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lc_pub_sg.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lc_pub_sg.id
}

# Egress Security Group Rules
resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  to_port           = 0
  from_port         = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lc_pub_sg.id
}
