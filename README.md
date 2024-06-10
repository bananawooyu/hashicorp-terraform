# terraform
deploy wordpress using terraform IaC with packer

### 사전 조건
 - HCP Terraform plus tier
 - VCS 연동 (github 사용)

#### Terraform IaC code

    IaC tree
    
    /terraform
     ├ versions.tf
     ├ provider.tf
     ├ output.tf
     ├ network.tf
     ├ variables.tf
     ├ main.tf
     └ README.md

------------------------

    <variable.tf>
    
    variable "prefix" {
      description = "This prefix will be included in the name of most resources."
      default = "jh"
    }
    
    variable "region" {
      type = string
      default = "us-east-2"
    
      description = "Enter the region to use for the environment. [Default : us-east-2]"
    }
    
    variable "availability_zone" {
      type = list(string)
      default = ["us-east-2a","us-east-2c"]
    
      description = "Enter the Availability Zone. [Default : us-east-2a,us-east-2c]"
    }
    
    variable "image_id" {
      type = string
      default = "ami-0b8414ae0d8d8b4cc"
      description = "Enter the id of the machine Image(AMI) to use for the server. [Default : Amazon Linux 2]"
    }
    
    variable "instance_type" {
      type = string
      default = "t3.micro"
    
      description = "Enter the instance type. [Default : t3.micro]"
    }
    
    variable "aws_key_pair" {
      type = string
      default = "tfc_ws_jh"
    
      description = "Enter the key pair name. [Default : tfc_ws_jh]"
    }
    
    variable "db_instance_type" {
      type = string
      default = "db.t3.micro"
    
      description = "Enter the db.instance type. [Default : db.t3.micro]"
    }
    variable "allocated_storage" {
      description = "The allocated storage in gigabytes"
      default = 5
    }
    variable "db_engine" {
      type = string
      default = "mysql"
    
      description = "Enter the db engine. [Default : mysql]"
    }
    
    variable "db_engine_version" {
      type = string
      default = "8.0.35"
    
      description = "Enter the db engine version. [Default : 8.0.35]"
    }
    
    variable "address_space" {
      description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
      default     = "10.0.0.0/16"
    }
    
    variable "web_subnet_prefix" {
      description = "The address prefix to use for the web subnet."
      default     = "10.0.0.0/24"
    }
    
    variable "db_subnet_prefix" {
      description = "The address prefix to use for the web subnet."
      default     = {
        subnet-2a = {
          az = "us-east-2a"
          cidr = "10.0.10.0/24"
          des = "2a"
        }
        subnet-2c = {
          az = "us-east-2c"
          cidr = "10.0.20.0/24"
          des = "2c"
        }
      }
    }
    
    variable "db_name" {
      description = "The DB name to create. If omitted, no database is created initially"
      default = "wordpress"
    }
    
    variable "admin_username" {
      description = "Administrator user name for mysql"
      default     = "hashicorp"
    }
    
    variable "password" {
      description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
      default     = "qwer1234"
    }
    
    variable "family" {
      description = "The family of the DB parameter group"
      type        = string
      default     = "mysql8.0"
    }
    
    variable "major_engine_version" {
      description = "Specifies the major version of the engine that this option group should be associated with"
      type        = string
      default     = "8.0"
    }
    
    variable "use_name_prefix" {
      description = "Determines whether to use `name` as is or create a unique name beginning with `name` as the specified prefix"
      type        = bool
      default     = false
    }
    
    variable "multi_az" {
      description = "Specifies if the RDS instance is multi-AZ"
      type        = bool
      default     = true
    }
    
------------------------

    <network.tf>
    
    resource "aws_vpc" "tfworkshop" {
      cidr_block           = var.address_space
      enable_dns_hostnames = true
    
      tags = {
        name        = "${var.prefix}-vpc-${var.region}"
        environment = "Production"
      }
    }
    
    resource "aws_subnet" "tfworkshop" {
      vpc_id     = aws_vpc.tfworkshop.id
      cidr_block = var.web_subnet_prefix
      availability_zone = var.availability_zone[0]
    
      tags = {
        name = "${var.prefix}-subnet"
      }
    }
    
    resource "aws_security_group" "tfworkshop" {
      name = "${var.prefix}-security-group"
      vpc_id = aws_vpc.tfworkshop.id
    
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
    
      ingress {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    
      egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
      }
    
      tags = {
        Name = "${var.prefix}-security-group"
      }
    }
    
    resource "aws_internet_gateway" "tfworkshop" {
      vpc_id = aws_vpc.tfworkshop.id
      tags = {
        Name = "${var.prefix}-internet-gateway"
      }
    }
    
    resource "aws_route_table" "tfworkshop" {
      vpc_id = aws_vpc.tfworkshop.id
      route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.tfworkshop.id
      }
    }
    
    resource "aws_route_table_association" "tfworkshop" {
      subnet_id      = aws_subnet.tfworkshop.id
      route_table_id = aws_route_table.tfworkshop.id
    }
    
    
    #################### DB ######################
    
    resource "aws_subnet" "tfworkshop_db" {
      for_each = var.db_subnet_prefix
      vpc_id     = aws_vpc.tfworkshop.id
      cidr_block = each.value["cidr"]
      availability_zone = each.value["az"]
    
      tags = {
        name = "${var.prefix}-subnet-${each.value["des"]}"
      }
    }
    
    resource "aws_route_table" "tfworkshop_db" {
      vpc_id = aws_vpc.tfworkshop.id
      route = []
    }
    
    resource "aws_route_table_association" "tfworkshop_db" {
      subnet_id      = values(aws_subnet.tfworkshop_db)[0].id
      route_table_id = aws_route_table.tfworkshop_db.id
    }
    
    resource "aws_security_group" "tfworkshop_db" {
      name = "${var.prefix}-db-security-group"
    
      vpc_id = aws_vpc.tfworkshop.id
    
      ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/24"]
      }
    
      egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
      }
    
      tags = {
        Name = "${var.prefix}-db-security-group"
      }
    }

------------------------

    <main.tf>
    
    locals {
      name_prefix = "jh-ws-rds"
      db_subnet_group_name = "${local.name_prefix}-tfworkshop-db-subnet-group"
    }
    
    data "aws_ami" "packer" {
      most_recent = true
    
      filter {
        name   = "name"
        values = ["jh-golden-image-*"]
      }
    
      owners = ["552166050235"] # private ami
    }
    
    resource "aws_eip" "tfworkshop" {
      instance = aws_instance.tfworkshop.id
      domain = "vpc"
    }
    
    resource "aws_eip_association" "tfworkshop" {
      instance_id   = aws_instance.tfworkshop.id
      allocation_id = aws_eip.tfworkshop.id
    }
    
    resource "aws_instance" "tfworkshop" {
      ami                         = data.aws_ami.packer.id
      instance_type               = var.instance_type
      key_name                    = var.aws_key_pair
      associate_public_ip_address = true
      subnet_id                   = aws_subnet.tfworkshop.id
      vpc_security_group_ids      = [aws_security_group.tfworkshop.id]
    
      user_data = <<EOF
        #!/bin/bash
        wget --no-check-certificate --no-proxy 'https://terraformworkshop-jh.s3.ap-northeast-2.amazonaws.com/wordpress.sh'
        chmod 777 wordpress.sh
        sh wordpress.sh
        sleep 5
      EOF
    
      tags = {
        Name = "${var.prefix}-tfworkshop-instance"
      }
    }
    
    module "rds" {
      source = "terraform-aws-modules/rds/aws"
      
      identifier = "tfworkshop-rds"
      
      engine            = "${var.db_engine}"
      engine_version    = "${var.db_engine_version}"
      instance_class    = "${var.db_instance_type}"
      allocated_storage = 5
      
      db_name  = "${var.db_name}"
      username = "${var.admin_username}"
      password = "${var.password}"
      port     = "3306"
      
      vpc_security_group_ids = ["${aws_security_group.tfworkshop_db.id}"]
      db_subnet_group_name = "${module.db_subnet_group.db_subnet_group_id}"
    
      family = var.family
      major_engine_version = var.major_engine_version
    
      maintenance_window = "Mon:00:00-Mon:03:00"
      backup_window      = "03:00-06:00"
      
      # DB subnet group
      subnet_ids = [values(aws_subnet.tfworkshop_db)[0].id,values(aws_subnet.tfworkshop_db)[1].id]
    }
    
    module "db_subnet_group" {
      source = "terraform-aws-modules/rds/aws//modules/db_subnet_group"
    
      name            = local.db_subnet_group_name
      subnet_ids      = [tostring(values(aws_subnet.tfworkshop_db)[0].id),tostring(values(aws_subnet.tfworkshop_db)[1].id)]
    }

>Terraform IaC 코드 : https://github.com/bananawooyu/terraform


---------------

#### wordpress 스크립트

    <wordpress.sh>
    
    #! /bin/bash
    
    yum install -y amazon-linux-extras
    amazon-linux-extras enable php7.4
    yum install php php-devel
    sudo yum install -y httpd
    sudo yum install -y php php-cli php-pdo php-fpm php-json php-mysqlnd
    sudo wget https://ko.wordpress.org/wordpress-6.5.3-ko_KR.tar.gz
    sleep 5
    sudo tar xvfz wordpress-6.5.3-ko_KR.tar.gz
    sudo cp -a ./wordpress/* /var/www/html/
    sudo chmod 707 /var/www/html/*
    
    sudo systemctl enable httpd
    sudo systemctl start httpd

#### 인프라 아키텍처
