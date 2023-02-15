resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.public_availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnet" {
  count      = length(var.private_subnets)
  vpc_id     = aws_vpc.dev-vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.private_availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id

  tags = {
    "Name" = "Internet-gateway"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    "Name" = "Public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.dev-vpc.id
  tags = {
    "Name" = "Private-route-table"
  }
}

resource "aws_route_table_association" "public-route-table-association" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-route-table-association" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}