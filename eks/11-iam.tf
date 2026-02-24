##############################
#                            #
#            role            #
#                            #
##############################

resource "aws_iam_role" "cluster" {
  name = "eks-byt-kevin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "node" {
  name = "eks-node-bye-kevin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "eks-node-role"
  }
}

##############################
#                            #
#        attachement         #
#                            #
##############################



# Pour que le CP puisse gérer le noeud
resource "aws_iam_role_policy_attachment" "role_attachement" {
  for_each = toset([
    "AmazonEC2ContainerRegistryReadOnly",
    "AmazonEKS_CNI_Policy",
    "AmazonEKSClusterPolicy",
    "AmazonEKSLocalOutpostClusterPolicy",
    "AmazonEKSServicePolicy",
    "AmazonEKSVPCResourceController",
    "AmazonEKSWorkerNodePolicy",
    "CloudWatchAgentServerPolicy",
    "ElasticLoadBalancingReadOnly"
  ])

  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  role       = aws_iam_role.node.name
}



