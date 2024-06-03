output "vpc_id" {
  value = aws_vpc.tfworkshop.id
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

output "aws_instance" {
  value = "${aws_instance.tfworkshop.id}"
}


output "wordpress_url" {
  value = "http://${aws_eip.tfworkshop.public_ip}"
}

output db_instance {
  value = "${module.db_instance.db_instance.id}"
}

output "db_endpoint" {
  value = "${module.db_instance.db_instance.endpoint}"
}

output "db_instance_name" {
  description = "The database name"
  value       = "${module.db_instance.this_db_instance_name}"
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = "${module.db_instance.this_db_instance_username}"
}

output "db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = "${var.password}"
}

