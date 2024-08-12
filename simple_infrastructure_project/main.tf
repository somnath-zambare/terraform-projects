terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.my-region
}

resource "aws_vpc" "my-vpc" {
  cidr_block       = var.vpc-cidr-block
  instance_tenancy = "default"

  tags = {
    Name = "my-vpc-1"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.public-subnet-cidr-block
   map_public_ip_on_launch = true  // given this to assign public ip 

  tags = {
    Name = "my-public-subnet"
  }
}


resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.my-vpc.id
  cidr_block = var.private-subnet-cidr-block

  tags = {
    Name = "my-private-subnet"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-internet"
  }
}

resource "aws_eip" "elastic-ip" {   // requires for nat gateway
  domain = "vpc"
}

resource "aws_nat_gateway" "nat-gateway" {     //require private servers to connect to internet without exposing ip
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "my-nat-gateway"
  }
}

resource "aws_route_table" "main-route-table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"   // allows to access ineternet via internet gateway, user can connect to this from internet frontend deployed here
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
   route {   //this route is useful for connecting servers present in vpc
    cidr_block = var.vpc-cidr-block
     gateway_id = "local"
  }


  tags = {
    Name = "main-route-table"
  }
}


resource "aws_route_table" "custom-route-table" {
  vpc_id = aws_vpc.my-vpc.id

 route {  //this route is useful for connecting servers present in vpc
    cidr_block = var.vpc-cidr-block
     gateway_id = "local"
  }

  route{
    cidr_block = "0.0.0.0/0"   //allowing to connect to internet via nat gateway so given internet cidr block with nat gateway for not exposing out device ip
    gateway_id = aws_nat_gateway.nat-gateway.id
  }


  tags = {
    Name = "custom-route-table"
  }
}

resource "aws_route_table_association" "private-subnet-assosiation" {   // this makes subnet private as routes in this table not having internet gateway so user can't connect servers in this but through nat gateway server can access internet
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.custom-route-table.id
}

resource "aws_route_table_association" "public-subnet-assosiation" {   // this makes subnet public as internet gateway is assosiated with this route and hence its server open for world
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.main-route-table.id
}

resource "aws_security_group" "security-group" {   // security groups allowing all traffic
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc.id
   egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

   ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  

  tags = {
    Name = "all-traffic-sg"
  }
}



resource "aws_instance" "public-server" {
  ami           = var.ami-id # us-west-2
  instance_type = var.instance_type
  key_name = "OregonKey"
  subnet_id = aws_subnet.public-subnet.id
   availability_zone = aws_subnet.public-subnet.availability_zone
  vpc_security_group_ids= [aws_security_group.security-group.id]
  tags = {
    Name = "my-public-server"
  }
}


resource "aws_instance" "private-server" {
  ami           = var.ami-id # us-west-2
  instance_type = var.instance_type
  key_name = "OregonKey"
  subnet_id = aws_subnet.private-subnet.id
  availability_zone = aws_subnet.private-subnet.availability_zone
  vpc_security_group_ids= [aws_security_group.security-group.id]
  tags = {
    Name = "my-private-server"
  }
}

output "public_ip_public_server" {
    value = aws_instance.public-server.public_ip 
}
