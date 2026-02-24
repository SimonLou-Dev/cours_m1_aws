resource "aws_eks_cluster" "bye_kevin" {
  name = "bye-kevin"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.35"

  vpc_config {
    subnet_ids              = module.eks.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name        = "eks-bye-kevin"
    Environment = "dev"
  }

  depends_on = [
    aws_iam_role_policy_attachment.role_attachement,
  ]
}

resource "aws_eks_node_group" "bye_kevin_group" {
  cluster_name    = aws_eks_cluster.bye_kevin.name
  node_group_name = "bye-kevin-group"
  node_role_arn   = aws_iam_role.node.arn

  subnet_ids = module.eks.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.bye_kevin_template.id
    version = aws_launch_template.bye_kevin_template.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "eks-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.role_attachement,
  ]
}

##############################
#                            #
#         IAM access         #
#                            #
##############################

resource "aws_eks_access_entry" "admin" {
  for_each = toset(var.admin_iam_arns)

  cluster_name  = aws_eks_cluster.bye_kevin.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  for_each = toset(var.admin_iam_arns)

  cluster_name  = aws_eks_cluster.bye_kevin.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

##############################
#                            #
#       launch template      #
#                            #
##############################

resource "aws_launch_template" "bye_kevin_template" {
  name_prefix = "bye-kevin-"

  vpc_security_group_ids = [aws_security_group.node_group.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node-bye-kevin"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "eks-launch-template"
  }
}

