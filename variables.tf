variable "region" {
  type = string
}

variable "aws_profile" {
  type = string
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
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "dev_domain" {
  type = string
}

variable "prod_domain" {
  type = string
}