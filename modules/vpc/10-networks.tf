##############################
#                            #
#            VPC             #
#                            #
##############################

locals {
  private_subnet_eks_tags = var.cluster_name != "" ? {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  } : {}

  public_subnet_eks_tags = var.cluster_name != "" ? {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  } : {}
}

resource "aws_vpc" "kevin_vpc" {
  cidr_block = var.cidr_block

  # Requis par EKS : sans ça les nodes ne peuvent pas résoudre l'endpoint
  # du cluster et restent en boucle "recovering resources" dans l'ASG.
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }
}

##############################
#                            #
#           Public           #
#           subnet           #
#                            #
##############################

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet)
  vpc_id            = aws_vpc.kevin_vpc.id
  cidr_block        = var.public_subnet[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(
    { Name = "${var.name}-public-${data.aws_availability_zones.azs.names[count.index]}" },
    local.public_subnet_eks_tags,
  )
}

##############################
#                            #
#           Public           #
#          routing           #
#                            #
##############################

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.kevin_vpc.id

  tags = {
    Name = "${var.name}-public-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.kevin_vpc.id

  tags = {
    Name = "${var.name}-public-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

##############################
#                            #
#          Private           #
#           subnet           #
#                            #
##############################

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet)
  vpc_id            = aws_vpc.kevin_vpc.id
  cidr_block        = var.private_subnet[count.index]
  availability_zone = data.aws_availability_zones.azs.names[count.index]

  tags = merge(
    { Name = "${var.name}-private-${data.aws_availability_zones.azs.names[count.index]}" },
    local.private_subnet_eks_tags,
  )
}

##############################
#                            #
#          private           #
#          routing           #
#                            #
##############################


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.kevin_vpc.id

  tags = {
    Name = "${var.name}-private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_eip" "external_ip" {
  domain = "vpc"

  tags = {
    Name = "${var.name}-private-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.external_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.name}-private-gateway"
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
