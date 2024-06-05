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
  "sudo wget --no-check-certificate --no-proxy 'https://terraformworkshop-jh.s3.ap-northeast-2.amazonaws.com/wordpress.sh'"
	"sudo chmod 777 wordpress.sh"
	"./wordpress.sh"
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