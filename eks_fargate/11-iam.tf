##############################
#                            #
#            role            #
#                            #
##############################

resource "aws_iam_role" "bisous_kevin" {
  name = "eks-node-bye-kevin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service =[
            "ec2.amazonaws.com",
            "eks-nodegroup.amazonaws.com",
            "eks.amazonaws.com",
            "ecs-tasks.amazonaws.com",
            "eks-fargate-pods.amazonaws.com"
          ]
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


resource "aws_iam_role_policy_attachment" "role_attachement" {
  for_each = toset([
    # --- Fargate ---
    "AmazonEKSFargatePodExecutionRolePolicy",
    # --- Cluster ---
    "AmazonEKSClusterPolicy",
    "AmazonEKSVPCResourceController",
    "AmazonEKSServicePolicy",
    "AmazonEKSLocalOutpostClusterPolicy",
    # --- Nodes ---
    "AmazonEKSWorkerNodePolicy",
    "AmazonEKS_CNI_Policy",
    "AmazonEC2ContainerRegistryReadOnly",
    "CloudWatchAgentServerPolicy",
    "ElasticLoadBalancingReadOnly",
  ])

  policy_arn = "arn:aws:iam::aws:policy/${each.key}"
  role       = aws_iam_role.bisous_kevin.name
}



