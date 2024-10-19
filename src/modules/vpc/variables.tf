variable "vpc_cidr" {
  description = "CIDR for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs for Subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for Public Subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for Private Subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "instance type"
  default       = "t2.medium"
}
variable "env_prefix" {
  description = "dev"
  default       = "dev"
}
variable "availability_zone" {
  description = "zone"
  default       = "us-east-1b"
}
