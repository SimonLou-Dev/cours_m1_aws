##############################
#                            #
#         Node group         #
#                            #
##############################

resource "aws_security_group" "node_group" {
  name        = "eks-node-bye-kevin"
  description = "Security group for EKS node group"
  vpc_id      = module.eks.vpc_id

  # Kubelet API : le control plane doit pouvoir appeler les nodes
  # (logs, exec, metrics-server)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "Kubelet API from control plane"
  }

  # NodePort range : si tu exposes des services en NodePort
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "NodePort services"
  }

  # ECR, S3, API server EKS, STS, CloudWatch → tout en HTTPS via NAT
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS outbound (ECR, S3, EKS API, CloudWatch)"
  }

  # DNS via le resolver VPC (adresse VPC+2)
  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.cidr_block]
    description = "DNS UDP"
  }

  egress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
    description = "DNS TCP"
  }

  tags = {
    Name = "eks-node-sg"
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

##############################
#                            #
#   Règles cross-SG          #
#   (évite la dépendance     #
#    circulaire Terraform)   #
#                            #
##############################

# SSH du bastion vers les nodes
resource "aws_security_group_rule" "node_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node_group.id
  source_security_group_id = aws_security_group.bastion_sg.id
  description              = "SSH from bastion"
}

resource "aws_security_group_rule" "bastion_ssh_to_nodes" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastion_sg.id
  source_security_group_id = aws_security_group.node_group.id
  description              = "SSH to EKS nodes"
}
