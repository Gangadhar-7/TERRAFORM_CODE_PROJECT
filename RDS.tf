
# Create a DB subnet group
resource "aws_db_subnet_group" "private_db_subnet_group" {
  name = "private_db_subnet_group"
  # subnet_ids = aws_subnet.private-subnet
  subnet_ids = [for s in aws_subnet.private-subnet : s.id]
}

# Create an RDS parameter group
resource "aws_db_parameter_group" "rds_parameter_group" {
  name_prefix = "rds-parameter-group"
  family      = "mysql8.0"
  description = "Custom parameter group for RDS instances"
}

resource "aws_kms_key" "rds_kms_key" {
  description = "My RDS KMS key"
}

# Create the RDS instance
resource "aws_db_instance" "rds_instance" {
  identifier             = "projectrds"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  allocated_storage      = 10
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_kms_key.arn
  db_subnet_group_name   = aws_db_subnet_group.private_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  publicly_accessible    = false
  multi_az               = false
  parameter_group_name   = aws_db_parameter_group.rds_parameter_group.name
  skip_final_snapshot    = true
}
