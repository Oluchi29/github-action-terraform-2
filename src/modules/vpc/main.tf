
provider "aws" {
  region = "us-east-1"
}



resource "aws_vpc" "ccVPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name    = "ccVPC"
    Project = "CC TF Demo"
  }
}

resource "aws_internet_gateway" "ccIGW" {
  vpc_id = aws_vpc.ccVPC.id
  tags = {
    Name    = "ccIGW"
    Project = "CC TF Demo"
  }
}

resource "aws_eip" "ccNatGatewayEIP1" {
  tags = {
    Name    = "ccNatGatewayEIP1"
    Project = "CC TF Demo"
  }
}
resource "aws_nat_gateway" "ccNatGateway1" {
  allocation_id = aws_eip.ccNatGatewayEIP1.id
  subnet_id     = aws_subnet.ccPublicSubnet1.id
  tags = {
    Name    = "ccNatGateway1"
    Project = "CC TF Demo"
  }
}
resource "aws_subnet" "ccPublicSubnet1" {
  vpc_id            = aws_vpc.ccVPC.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name    = "ccPublicSubnet1"
    Project = "CC TF Demo"
  }
}

resource "aws_eip" "ccNatGatewayEIP2" {
  tags = {
    Name    = "ccNatGatewayEIP2"
    Project = "CC TF Demo"
  }
}
resource "aws_nat_gateway" "ccNatGateway2" {
  allocation_id = aws_eip.ccNatGatewayEIP2.id
  subnet_id     = aws_subnet.ccPublicSubnet1.id
  tags = {
    Name    = "ccNatGateway2"
    Project = "CC TF Demo"
  }
}
resource "aws_subnet" "ccPublicSubnet2" {
  #vpc_id            = aws_vpc.ccVPC.id
  vpc_id            = aws_vpc.ccVPC.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name    = "ccPublicSubnet2"
    Project = "CC TF Demo"
  }
}

resource "aws_subnet" "ccPrivateSubnet1" {
  vpc_id            = aws_vpc.ccVPC.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = var.availability_zones[0]
  tags = {
    Name    = "ccPrivateSubnet1"
    Project = "CC TF Demo"
  }
}
resource "aws_subnet" "ccPrivateSubnet2" {
  vpc_id            = aws_vpc.ccVPC.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = var.availability_zones[1]
  tags = {
    Name    = "ccPrivateSubnet2"
    Project = "CC TF Demo"
  }
}

resource "aws_route_table" "ccPublicRT" {
  vpc_id = aws_vpc.ccVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ccIGW.id
  }
  tags = {
    Name    = "ccPublicRT"
    Project = "CC TF Demo"
  }
}
resource "aws_route_table" "ccPrivateRT1" {
  vpc_id = aws_vpc.ccVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ccNatGateway1.id
  }
  tags = {
    Name    = "ccPrivateRT1"
    Project = "CC TF Demo"
  }
}
resource "aws_route_table" "ccPrivateRT2" {
  vpc_id = aws_vpc.ccVPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ccNatGateway2.id
  }
  tags = {
    Name    = "ccPrivateRT2"
    Project = "CC TF Demo"
  }
}

resource "aws_route_table_association" "ccPublicRTassociation1" {
  subnet_id      = aws_subnet.ccPublicSubnet1.id
  route_table_id = aws_route_table.ccPublicRT.id
}
resource "aws_route_table_association" "ccPublicRTassociation2" {
  subnet_id      = aws_subnet.ccPublicSubnet2.id
  route_table_id = aws_route_table.ccPublicRT.id
}
resource "aws_route_table_association" "ccPrivateRTassociation1" {
  subnet_id      = aws_subnet.ccPrivateSubnet1.id
  route_table_id = aws_route_table.ccPrivateRT1.id
}
resource "aws_route_table_association" "ccPrivateRTassociation2" {
  subnet_id      = aws_subnet.ccPrivateSubnet2.id
  route_table_id = aws_route_table.ccPrivateRT2.id
}
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.ccVPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  #ami                         = data.aws_ami.latest-amazon-linux-image.id
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = "oluchi"
  subnet_id                   = aws_subnet.ccPublicSubnet2.id
  vpc_security_group_ids      = [aws_default_security_group.default-sg.id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  user_data                   = file("install-nginx.sh")
  tags = {
    Name = "${var.env_prefix}-web-server"
  }
} 