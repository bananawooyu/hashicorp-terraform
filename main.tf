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
  ami                         = data.aws_ami.packer.path
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.tfworkshop.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.tfworkshop.id
  vpc_security_group_ids      = [aws_security_group.tfworkshop.id]

  tags = {
    Name = "${var.prefix}-tfworkshop-instance"
  }
}

resource "null_resource" "configure-wordpress-app" {
  depends_on = [aws_eip_association.tfworkshop]

  triggers = {
    build_number = timestamp()
  }

  provisioner "file" {
    source      = "files/"
    destination = "/home/ec2-user/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.tfworkshop.private_key_pem
      host        = aws_eip.tfworkshop.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo wget --no-check-certificate --no-proxy 'https://terraformworkshop-jh.s3.ap-northeast-2.amazonaws.com/wordpress.sh'",
			"sudo chmod +x wordpress.sh",
			"./wordpress.sh",
			"rm wordpress.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.tfworkshop.private_key_pem
      host        = aws_eip.tfworkshop.public_ip
    }
  }
}

locals {
  private_key_filename = "tfc_ws_jh"
}

resource "aws_key_pair" "tfworkshop" {
  key_name   = local.private_key_filename
  public_key = tls_private_key.tfworkshop.public_key_openssh
}


######### DB 인스턴스 추가 필요

resource "aws_db_subnet_group" "db_subnet" {
  count = "${var.count}"

  name_prefix = "${var.name_prefix}"
  description = "Database subnet group for ${var.identifier}"
  subnet_ids  = ["${var.subnet_ids}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.identifier)))}"
}

resource "aws_db_instance" "db_instance" {
  identifier = "${var.identifier}"

  engine            = "${var.engine}"
  engine_version    = "${var.engine_version}"
  instance_class    = "${var.instance_class}"
  allocated_storage = "${var.allocated_storage}"
  storage_type      = "${var.storage_type}"

  db_name = "${var.db_name}"
  username = "${var.username}"
  password = "${var.password}"
  port     = "${var.port}"

  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  db_subnet_group_name   = "${var.db_subnet_group_name}"
  parameter_group_name   = "${var.parameter_group_name}"

  multi_az            = "${var.multi_az}"
  iops                = "${var.iops}"
  publicly_accessible = "${var.publicly_accessible}"

  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"
  apply_immediately           = "${var.apply_immediately}"
  maintenance_window          = "${var.maintenance_window}"
  skip_final_snapshot         = "${var.skip_final_snapshot}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"

  backup_retention_period = "${var.backup_retention_period}"
  backup_window           = "${var.backup_window}"

  tags = "${merge(var.tags, map("Name", format("%s", var.identifier)))}"
}