
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
#         networking         #
#                            #
##############################

variable "cidr_block" {
  description = "VPC CIDR block"
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
#          instance          #
#                            #
##############################

variable "ssh_public_key" {
  description = "Contenu de la clé publique SSH (ex: cat ~/.ssh/id_rsa.pub)"
  type        = string
}

##############################
#                            #
#           access           #
#                            #
##############################

variable "admin_iam_arns" {
  description = "Liste des ARN IAM ayant accès admin au cluster (ex: arn:aws:iam::123456789:user/mon-user)"
  type        = list(string)
  default     = []
}
