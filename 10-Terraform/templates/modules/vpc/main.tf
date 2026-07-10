resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block               = cidrsubnet(var.cidr_block, 8, 1)
  map_public_ip_on_launch  = true
}

resource "aws_security_group" "public" {
  name   = "module-public-sg"
  vpc_id = aws_vpc.this.id
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
