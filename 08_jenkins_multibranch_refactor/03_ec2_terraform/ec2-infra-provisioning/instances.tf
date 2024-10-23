# ENI
resource "aws_network_interface" "lc_www1_eth0" {
  description     = "lc www1 eth0"
  subnet_id       = aws_subnet.lc_pub.id
  private_ips     = [var.private_instance_ip]
  security_groups = [aws_security_group.lc_pub_sg.id]

  tags = {
    "Name" = "lc ww1 eth0"
  }
}

# Elastic IP Address
resource "aws_eip" "lc_www1_eip" {
  domain = "vpc"
  depends_on = [
    aws_internet_gateway.lc_igw
  ]
}

resource "aws_eip_association" "eip_assoc" {
  network_interface_id = aws_network_interface.lc_www1_eth0.id 
  allocation_id = aws_eip.lc_www1_eip.id 
  private_ip_address = var.private_instance_ip
}

resource "aws_instance" "instance" {
  ami = var.ami
  key_name = var.key_name
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.lc_www1_eth0.id 
    device_index = 0
  }

  user_data = file("${path.module}/docker-installation.sh")

  tags = {
    "Name" = "lc-www1"
  }
}
