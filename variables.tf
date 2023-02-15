variable "region" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_availability_zones" {
  type = list(string)
}

variable "private_availability_zones" {
  type = list(string)
}