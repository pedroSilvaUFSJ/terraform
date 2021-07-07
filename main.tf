
provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_key_pair" "terraform-pair" {
  key_name = var.key_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqr+L5EIKgn6WNNZDAN9vxXTVXkx1q03HhX/gfQRufE7zBgNJNUIjXOmc9wiBahPpykatpn24XFWG1tBJ/mBFCDXZY3QhrTSVsdzl3g5U86AlwRtlKIl8FikiyN0xVyNC60GjKexq37sbVAJuKA2dF5ip+VnxVEcUcIH47MnbLLH5496kcmupW3kCKKX28djoljKjuFiBKf6ajW6pQ7xcHQG52M98ZikET+0ZC8lAgDCDwV5wznQDFr4MqJ+jZSNyrmwcdS5bXNk2FTsZyhRwREWvIO2eB13HXvaKMz9lG7oJx79Eg2KWlkZkE+urY8AfS2f01gX8v6raEw6cf2vFdQ== rsa-key-20210707"
}

resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terraform-production"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod-vpc.id
  tags = {
    Name = "terraform-gateway"
  }
}

resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Prod"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = var.subnet_prefix
  availability_zone = var.availability_zone
  tags = {
    Name = "prod-subnet"
  }
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.prod-vpc.id
  route_table_id = aws_route_table.prod-route-table.id
}

resource "aws_security_group" "allow-web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

resource "aws_instance" "web-terraform-server-instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bach -c 'echo my very first web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "terraform-project"
  }
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}
