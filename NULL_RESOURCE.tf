output "rds_host" {
  value = "database-1.c7vq7maqswxz.us-east-1.rds.amazonaws.com"
}

output "rds_username" {
  value = "admin"
}

output "rds_db_name" {
  value = "simple_website"
}

# Generate the env_variables.sh file after obtaining RDS details
resource "null_resource" "generate_env_file" {
  provisioner "local-exec" {
    command = <<EOT
echo "export HOST=${aws_db_instance.rds_instance.address}" > env_variables.sh
echo "export USER_NAME=${aws_db_instance.rds_instance.username}" >> env_variables.sh
echo "export DATABASE=${var.db_name}" >> env_variables.sh
# Add more variables as needed
EOT
  }
  # Run the provisioner when RDS details are available
  depends_on = [aws_db_instance.rds_instance]
}
