
##############################
#                            #
#   Configuration provider   #
#                            #
##############################

variable "region" {
  description = "Region AWS"
}

##############################
#                            #
#            VPC             #
#                            #
##############################

variable "cidr_block" {
  description = "VPC CIDR block"
}

variable "name" {
  description = "Nom du vpc"
}

variable "private_subnet" {
  type        = list(string)
  description = "private subnet"
}

variable "public_subnet" {
  type        = list(string)
  description = "Public subnet"
}
