output "vpc_id" {
  value = "${vpc_id.tfworkshop.id}"  
}

output "subnet_id" {
  value = aws_subnet.tfworkshop.id
}

output "subnet_cidr" {
  value = aws_subnet.tfworkshop.cidr_block
}

output instance {
  value = aws_instance.tfworkshop.ami
}

output db_instance {
  value = aws_db_instance.db_instance.id
}

output "db_endpoint" {
  value = aws_db_instance.db_instance.endpoint
}

output "aws_instance" {
  value = "${aws_instance.tfworkshop.id}"
}


output "wordpress_url" {
  value = "http://${aws_eip.tfworkshop.public_ip}"
}

