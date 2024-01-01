resource "aws_security_group" "app-lb-sg" {
  name        = "${var.aws_profile}-app-load-balancer-sg"
  description = "Load balancer security group to allow inbound traffic from the Internet"
  vpc_id      = aws_vpc.dev-vpc.id
  depends_on  = [aws_vpc.dev-vpc]
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_profile}-app-load-balancer-sg"
  }
}

resource "aws_security_group" "app-sg" {
  name        = "${var.aws_profile}-application-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.dev-vpc.id
  depends_on  = [aws_vpc.dev-vpc]
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.app-lb-sg.id]
  }
#   ingress {
#     from_port       = 0
#     to_port         = 65000
#     protocol        = "tcp"
#     security_groups = [aws_security_group.app-lb-sg.id]
#   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_profile}-application-sg"
  }
}

resource "aws_security_group" "db-sg" {
  name        = "${var.aws_profile}-database-sg"
  description = "Database security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.dev-vpc.id
  depends_on  = [aws_vpc.dev-vpc]
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }
  tags = {
    Name = "${var.aws_profile}-database-sg"
  }
}