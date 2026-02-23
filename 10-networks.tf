resource "aws_vpc" "kevin_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = "Kevin VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)
  vpc_id            = aws_vpc.kevin_vpc.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  tags = {
    Name = "Public-Subnet ${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet)
  vpc_id            = aws_vpc.kevin_vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = {
    "Name" = "Private-Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.kevin_vpc.id

  tags = {
    Name = "gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.kevin_vpc.id

  tags = {
    Name = "public-router"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id

  depends_on = [ aws_internet_gateway.gateway, aws_route_table.public_route_table ]
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [ aws_subnet.public_subnet, aws_route_table.public_route_table ]
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.kevin_vpc.id

  tags = {
    Name = "private-router"
  }

  depends_on = [ aws_vpc.kevin_vpc ]
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [ aws_subnet.private_subnet, aws_route_table.private_route_table ]
}


resource "aws_eip" "external_ip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.external_ip.id
  vpc_id            = aws_vpc.kevin_vpc.id
  availability_mode = "regional"
  tags = {
    Name = "nat-gateway"
  }

  depends_on = [ aws_vpc.kevin_vpc, aws_eip.external_ip]
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id

  depends_on = [ aws_eip.external_ip, aws_route_table.private_route_table, aws_nat_gateway.nat_gateway ]
}