### Simple AWS network infrastructure by using Terraform

**Following resources are created by using above code:**
-VPC
-Public and Private Subnets
-Internet Gateway
-NAT Gateway
-Main and Custom Route Tables
-Instance in public as well as private subnet (Both instance should able to access internet (For Private instance use NAT Gateway for security) and public server should be accessible through internet)
-Security Group
-Key-Pair

**Please change below resources values according to your design in terraform.tfvars files.**
vpc-cidr-block = VPC CIDR 
private-subnet-cidr-block = Subnet CIDR which you want to give to your Private Subnet
public-subnet-cidr-block = SUBNET CIDR which you want to give to your Public Subnet
my-region = AWS Region in which you want to create network
ami-id = Give ami id from aws according to your need
instance_type = Give instance type according to your need

**This network infrastructure allows :**
- Ingress ssh, http, https and egress all traffic via internet gateway to EC2 instance in public subnet
- Egress traffic to internet via NAT gateway from private subnet

**Steps to run the code :**
1- Configure IAM user using AWS CLI
2- Copy terraform code in one folder
3- Open VS Code in that folder and open terminal in VS code
4- Run command 'terraform init'
5-After that run command 'terraform plan'
6-Give key pair name
7-Run command 'terraform apply' and again enter key-pair name and give approval
8-After successful resource creation add '.pem' extenstion in key name which is saved in local
9-While connecting to instance change key permission using 'chmod 400 {key name}' if you are using Linux or MacOS
10-Replace KeyPair name "OregonKey" in EC2 instance resource with key pair which is avaialble in your AWS and local system.(I will update this part)

Resources will be created by following above steps

**How to Clean the Environment**                                                                                

11- To clean up run command 'terraform destroy' this will delete all the created resources