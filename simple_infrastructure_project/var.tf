variable "my-region" {
  default= "us-east-1"
}

variable "vpc-cidr-block" {
  default = "172.16.0.0/16"
}

variable "public-subnet-cidr-block" {
  default = "172.16.1.0/24"
}

variable "private-subnet-cidr-block" {
  default = "172.16.2.0/24"
}

variable "ami-id" {
  default = "ami-0a38c1c38a15fed74"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "availability_zone" {
  default = "us-east-1a"
}

