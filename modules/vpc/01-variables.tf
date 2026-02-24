
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

##############################
#                            #
#       EKS (optionnel)      #
#                            #
##############################

variable "cluster_name" {
  description = "Nom du cluster EKS. Si renseigné, ajoute les tags kubernetes.io sur les subnets."
  type        = string
  default     = ""
}
