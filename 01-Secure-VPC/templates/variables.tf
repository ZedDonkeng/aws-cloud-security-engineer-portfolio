variable "aws_region" {
  default = "us-east-1"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}
variable "availability_zone" {
  default = "us-east-1a"
}
variable "my_ip_cidr" {
  description = "Your public IP in CIDR notation, e.g. 203.0.113.4/32"
  type        = string
}
