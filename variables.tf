variable "region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile" {
  type = string
  default = "default"
}

variable "cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = number
  default = 2
}

variable "private_subnets" {
  type = number
  default = 2
}

variable "db_name" {
  type = string
  default = "sample"
}

variable "db_username" {
  type = string
  default = "admin"
}

variable "db_password" {
  type = string
  default = "admin123"
}

variable "dev_domain" {
  type = string
  default = "*.gangadharrecruitcrm.shop"
}

variable "prod_domain" {
  type = string
  default = "*.gangadharrecruitcrm.shop"
}