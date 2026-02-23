
##############################
#                            #
#   Configuration provider   #
#                            #
##############################

region = "eu-west-3"

##############################
#                            #
#         networking         #
#                            #
##############################

cidr_block = "10.0.0.0/16"

private_subnet = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

public_subnet = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

##############################
#                            #
#          instance          #
#                            #
##############################

ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2wznKtUWNBnbStppdAXsJSdZXrTqtrMp5sDQwPRQpR simsi@laptop-sim"

