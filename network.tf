resource "aws_vpc" "dev-vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = "${var.aws_profile}-vpc"
  }
}

data "aws_availability_zones" "all" {
  state = "available"
}

resource "aws_subnet" "public-subnet" {
  count                   = var.public_subnets
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.all.names, count.index % length(data.aws_availability_zones.all.names))
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${aws_vpc.dev-vpc.id}-Public subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private-subnet" {
  count             = var.private_subnets
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, count.index + 1)
  availability_zone = element(data.aws_availability_zones.all.names, count.index % length(data.aws_availability_zones.all.names))

  tags = {
    Name = "${aws_vpc.dev-vpc.id}-Private subnet ${count.index + 1}"
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
  count          = var.public_subnets
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-route-table-association" {
  count          = var.private_subnets
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route-table.id
}