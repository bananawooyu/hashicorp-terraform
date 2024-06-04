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
  default = "db.t3.micro"

  description = "Enter the db.instance type. [Default : db.t2.micro]"
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