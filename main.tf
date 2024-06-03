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
  key_name                    = var.aws_key_pair
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
      private_key = var.aws_key_pair
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
      private_key = var.aws_key_pair
      host        = aws_eip.tfworkshop.public_ip
    }
  }
}