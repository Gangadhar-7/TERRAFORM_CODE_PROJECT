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

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.aws_profile}-application-sg"
  }
}

resource "aws_security_group_rule" "database_inbound_rule" {
  type        = "ingress"
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  security_group_id = aws_security_group.db-sg.id
  source_security_group_id = aws_security_group.app-sg.id
}

resource "aws_security_group" "db-sg" {
  name        = "${var.aws_profile}-database-sg"
  description = "Database security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.dev-vpc.id
  depends_on  = [aws_vpc.dev-vpc]

  tags = {
    Name = "${var.aws_profile}-database-sg"
  }
}

data "aws_ami" "custom_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["csye6225*"]
  }
}

# Generate a random name for the S3 bucket.

resource "random_id" "random" {
  byte_length = 4
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = "my-${var.aws_profile}-bucket-${random_id.random.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.private_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.private_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.private_bucket.id
  rule {
      id      = "transition_to_standard_ia"    
      status  = "Enabled"
      filter {}
      transition {
        days          = 30
        storage_class = "STANDARD_IA"
      }
  }
}

# Create an IAM Role for S3 Access.

resource "aws_iam_role" "EC2-CSYE6225" {
  name = "EC2-CSYE6225"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create an S3 access policy to the above role.

resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  description = "Policy for accessing S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.private_bucket.arn}",
          "${aws_s3_bucket.private_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Attach the policy to the created role.

resource "aws_iam_role_policy_attachment" "s3_access_role_attachment" {
  policy_arn = aws_iam_policy.WebAppS3.arn
  role       = aws_iam_role.EC2-CSYE6225.name
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2_profile"
  role = aws_iam_role.EC2-CSYE6225.name
}

# Create access key pair.

resource "aws_key_pair" "ec2keypair" {
  key_name   = "ec2.pub"
  public_key = file("~/.ssh/ec2.pub")
}

resource "aws_instance" "webapp-server" {
  ami                     = data.aws_ami.custom_ami.id
  instance_type           = "t2.micro"
  iam_instance_profile    = aws_iam_instance_profile.ec2_profile.name
  disable_api_termination = false
  ebs_optimized           = false
  root_block_device {
    volume_size           = 50
    volume_type           = "gp2"
    delete_on_termination = true
  }
  vpc_security_group_ids = [aws_security_group.app-sg.id]
  subnet_id              = aws_subnet.public-subnet[0].id
  key_name               = aws_key_pair.ec2keypair.key_name

  tags = {
    Name = "Webapp EC2 Instance"
  }
}