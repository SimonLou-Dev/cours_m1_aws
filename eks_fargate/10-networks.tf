module "eks" {
  source = "../modules/vpc"

  name         = "eks-vpc"
  cluster_name = "bye-kevin"

  cidr_block     = var.cidr_block
  public_subnet  = var.public_subnet
  private_subnet = var.private_subnet
  region         = var.region
}