provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_key_pair" "tf_keypair" {
  key_name   = "tf_keypair"
  public_key = var.public_key

  tags = {
    Name = "tf_keypair"
  }
}

variable "public_key" {
  description = "SSH public key for EC2 access"
  type        = string
}

data "aws_ami" "LatestAmi" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}


resource "aws_vpc" "MyVPC08" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true


  tags = {
    Name = "MyVPC08"
  }
}

resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC08.id

  tags = {
    Name = "MyIGW"
  }
}

resource "aws_subnet" "MyPublic1Subnet" {
  vpc_id                  = aws_vpc.MyVPC08.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MyPublic1Subnet"
  }
}

resource "aws_route_table" "MyPublic1Routing" {
  depends_on = [aws_internet_gateway.MyIGW]

  vpc_id = aws_vpc.MyVPC08.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }

  tags = {
    Name = "MyPublic1Routing"
  }
}

resource "aws_route_table_association" "MyPublic1RouteTableAssociation" {
  subnet_id      = aws_subnet.MyPublic1Subnet.id
  route_table_id = aws_route_table.MyPublic1Routing.id
}

resource "aws_eip" "MyNatGW1EIP" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "MyNatGW1" {
  depends_on    = [aws_internet_gateway.MyIGW]
  allocation_id = aws_eip.MyNatGW1EIP.id
  subnet_id     = aws_subnet.MyPublic1Subnet.id

  tags = {
    Name = "MyNatGW1"
  }
}

resource "aws_subnet" "MyPrivate1Subnet" {
  vpc_id                  = aws_vpc.MyVPC08.id
  cidr_block              = "10.0.100.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false
  tags = {
    Name = "MyPrivate1Subnet"
  }
}

resource "aws_route_table" "MyPrivate1Routing" {
  depends_on = [aws_nat_gateway.MyNatGW1]

  vpc_id = aws_vpc.MyVPC08.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.MyNatGW1.id
  }

  tags = {
    Name = "MyPrivate1Routing"
  }
}

resource "aws_route_table_association" "MyPrivate1RouteTableAssociation" {
  subnet_id      = aws_subnet.MyPrivate1Subnet.id
  route_table_id = aws_route_table.MyPrivate1Routing.id
}

resource "aws_subnet" "MyPublic2Subnet" {
  vpc_id                  = aws_vpc.MyVPC08.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true
  tags = {
    Name = "MyPublic2Subnet"
  }
}

resource "aws_route_table" "MyPublic2Routing" {
  depends_on = [aws_internet_gateway.MyIGW]

  vpc_id = aws_vpc.MyVPC08.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }

  tags = {
    Name = "MyPublic2Routing"
  }
}

resource "aws_route_table_association" "MyPublic2RouteTableAssociation" {
  subnet_id      = aws_subnet.MyPublic2Subnet.id
  route_table_id = aws_route_table.MyPublic2Routing.id
}

resource "aws_eip" "MyNatGW2EIP" {
  domain = "vpc"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "MyNatGW2" {
  depends_on    = [aws_internet_gateway.MyIGW]
  allocation_id = aws_eip.MyNatGW2EIP.id
  subnet_id     = aws_subnet.MyPublic2Subnet.id

  tags = {
    Name = "MyNatGW2"
  }
}

resource "aws_subnet" "MyPrivate2Subnet" {
  vpc_id                  = aws_vpc.MyVPC08.id
  cidr_block              = "10.0.200.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = false
  tags = {
    Name = "MyPrivate2Subnet"
  }
}

resource "aws_route_table" "MyPrivate2Routing" {
  depends_on = [aws_nat_gateway.MyNatGW2]

  vpc_id = aws_vpc.MyVPC08.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.MyNatGW2.id
  }

  tags = {
    Name = "MyPrivate2Routing"
  }
}

resource "aws_route_table_association" "MyPrivate2RouteTableAssociation" {
  subnet_id      = aws_subnet.MyPrivate2Subnet.id
  route_table_id = aws_route_table.MyPrivate2Routing.id
}

resource "aws_security_group" "MySecugroup" {
  name        = "MySecugroup"
  description = "Permit http,https,ssh and icmp"
  vpc_id      = aws_vpc.MyVPC08.id
  tags = {
    Name = "MySecugroup"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


