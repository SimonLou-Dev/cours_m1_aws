

variable "region" {
    default = "eu-west-3"
}

variable "cidr_block" {
    default = "10.0.0.0/16"
}

variable "private_subnet" {
    type = list(string)
    default = ["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]
    description = "private subnet"
}

variable "public_subnet" {
    type = list(string)
    default = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
    description = "Public subnet"
}

variable "ssh_public_key" {
  description = "Contenu de la clé publique SSH (ex: cat ~/.ssh/id_rsa.pub)"
  type        = string
}