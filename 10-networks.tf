resource "aws_vpc" "public" {
  cidr_block       = "10.0.0.0/24"

  tags = {
    Name = "public"
  }
}


resource "aws_vpc" "admin" {
  cidr_block       = "172.16.0.0/24"

  tags = {
    Name = "admin"
  }
}