##############################
#                            #
#            VPC             #
#                            #
##############################

output "vpc_id" {
  value = aws_vpc.kevin_vpc.id
}

output "vpc_arn" {
  value = aws_vpc.kevin_vpc.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.kevin_vpc.cidr_block
}

##############################
#                            #
#        Public subnet       #
#                            #
##############################

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "public_subnet_cidrs" {
  value = aws_subnet.public_subnet[*].cidr_block
}

##############################
#                            #
#       Private subnet       #
#                            #
##############################

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}

output "private_subnet_cidrs" {
  value = aws_subnet.private_subnet[*].cidr_block
}

##############################
#                            #
#       Internet Gateway     #
#                            #
##############################

output "internet_gateway_id" {
  value = aws_internet_gateway.gateway.id
}

##############################
#                            #
#        Route tables        #
#                            #
##############################

output "public_route_table_id" {
  value = aws_route_table.public_route_table.id
}

output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

##############################
#                            #
#         NAT Gateway        #
#                            #
##############################

output "nat_gateway_id" {
  value = aws_nat_gateway.nat_gateway.id
}

output "nat_gateway_public_ip" {
  value = aws_eip.external_ip.public_ip
}

output "eip_id" {
  value = aws_eip.external_ip.id
}
