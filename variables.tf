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
  type = string
  default = "us-east-2a"

  description = "Enter the Availability Zone. [Default : us-east-2a]"
}

variable "image_id" {
  type = string
  default = "ami-0b8414ae0d8d8b4cc"
  description = "Enter the id of the machine Image(AMI) to use for the server. [Default : Amazon Linux 3]"
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
  default = "db.t2.micro"

  description = "Enter the db.instance type. [Default : db.t2.micro]"
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
  default     = "10.0.10.0/24"
}

variable "admin_username" {
  description = "Administrator user name for mysql"
  default     = "hashicorp"
}
