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
  vpc_id     = aws_vpc.tfworkshop.id
  cidr_block = var.db_subnet_prefix

  tags = {
    name = "${var.prefix}-subnet"
  }
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

resource "aws_route_table" "tfworkshop_db" {
  vpc_id = aws_vpc.tfworkshop.id

  route {
    cidr_block = "10.0.0.0/24"
  }
}

# resource "aws_route_table_association" "tfworkshop_db" {
#   subnet_id      = aws_subnet.tfworkshop_db.id
#   route_table_id = aws_route_table.tfworkshop.id
# }