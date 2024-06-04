locals {
  name_prefix = "jh-ws-rds"
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

  tags = {
    Name = "${var.prefix}-tfworkshop-instance"
  }
}

# resource "null_resource" "configure-wordpress-app" {
#   depends_on = [aws_eip_association.tfworkshop]

#   triggers = {
#     build_number = timestamp()
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo wget --no-check-certificate --no-proxy 'https://terraformworkshop-jh.s3.ap-northeast-2.amazonaws.com/wordpress.sh'",
# 			"sudo chmod +x wordpress.sh",
# 			"./wordpress.sh",
# 			"rm wordpress.sh"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = "${file("E:\Lab Project\hcp terraform workshop\tfc_ws_jh.ppk")}"
#       host        = aws_eip.tfworkshop.public_ip
#     }
#   }
# }

module "rds" {
  source = "terraform-aws-modules/rds/aws"
  
  identifier = "tfworkshop_rds"
  
  engine            = "${var.db_engine}"
  engine_version    = "${var.db_engine_version}"
  instance_class    = "${var.db_instance_type}"
  allocated_storage = 5
  
  db_name  = "${var.db_name}"
  username = "${var.admin_username}"
  password = "${var.password}"
  port     = "3306"
  
  vpc_security_group_ids = ["${aws_security_group.tfworkshop_db.id}"]

  family = var.family
  major_engine_version = var.major_engine_version

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"
  
  # DB subnet group
  subnet_ids = ["${aws_subnet.tfworkshop_db.id}"]
}