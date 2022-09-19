resource "aws_vpc" "theo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "theo-vpc ${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "random_shuffle" "azs" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}


resource "aws_subnet" "theo_priv_sub" {
  count                   = var.priv_sub_count
  vpc_id                  = aws_vpc.theo_vpc.id
  cidr_block              = var.priv_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.azs.result[count.index]
  tags = {
    Name = "theo-priv_sub ${count.index + 1}"
  }
}

resource "aws_subnet" "theo_pub_sub" {
  count                   = var.pub_sub_count
  vpc_id                  = aws_vpc.theo_vpc.id
  cidr_block              = var.pub_sub_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.azs.result[count.index]
  tags = {
    Name = "theo-pub_sub ${count.index + 1}"
  }

}

resource "aws_internet_gateway" "theo_ig" {
  vpc_id = aws_vpc.theo_vpc.id
  tags = {
    Name = "theo-ig"
  }
}

resource "aws_route_table" "theo_rt" {
  vpc_id = aws_vpc.theo_vpc.id
  tags = {
    Name = "theo-rt"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.theo_ig.id
  }
}


resource "aws_route_table_association" "theo_rta_pub" {
  count          = var.pub_sub_count
  subnet_id      = aws_subnet.theo_pub_sub[count.index].id
  route_table_id = aws_route_table.theo_rt.id

}

resource "aws_default_route_table" "theo_priv_rt" {
  default_route_table_id = aws_vpc.theo_vpc.default_route_table_id
  tags = {
    Name = "theo-private"
  }
}


resource "aws_security_group" "theo" {
  for_each    = var.sec_group
  name        = each.value.name
  vpc_id      = aws_vpc.theo_vpc.id
  description = each.value.description


  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from
      to_port     = ingress.value.to
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks

    }

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_db_subnet_group" "theo_db_sub" {
  count      = var.db_subnet_group == true ? 1 : 0
  name       = "theo_db_sub_g"
  subnet_ids = aws_subnet.theo_priv_sub.*.id
}


