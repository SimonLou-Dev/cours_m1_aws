##############################
#                            #
#          Fargate           #
#                            #
##############################

resource "aws_security_group" "fargate_sg" {
  name        = "eks-fargate-bye-kevin"
  description = "Security group for EKS Fargate pods"
  vpc_id      = module.eks.vpc_id

  # Ingress HTTP du VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "HTTP from VPC"
  }

  # Ingress HTTPS du VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "HTTPS from VPC"
  }

  # Kubelet API
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "Kubelet API"
  }

  # Egress HTTPS (ECR, S3, EKS API, CloudWatch)
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  # Egress HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP outbound"
  }

  # DNS UDP
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.cidr_block]
    description = "DNS UDP"
  }

  # DNS TCP
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "DNS TCP"
  }

  tags = {
    Name = "eks-fargate-sg"
  }
}

##############################
#                            #
#           Bastion          #
#                            #
##############################

resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "SSH public vers le bastion"
  vpc_id      = module.eks.vpc_id

  # SSH public entrant
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH public"
  }

  # HTTPS pour les mises à jour système
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound"
  }

  # HTTP pour les mises à jour système
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP outbound"
  }

  tags = {
    Name = "bastion-sg"
  }
}
