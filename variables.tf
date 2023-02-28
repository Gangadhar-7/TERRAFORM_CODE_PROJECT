variable "region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
  default = "dev"
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = number
}

variable "private_subnets" {
  type = number
}

variable "db_name" {
  type = string
  default = "webapp"
}

variable "db_username" {
  type = string
  default = "root"
}

variable "db_password" {
  type = string
  default = "Kissanime123"
}