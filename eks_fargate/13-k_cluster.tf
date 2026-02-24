resource "aws_eks_cluster" "bye_kevin" {
  name = "bye-kevin"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.bisous_kevin.arn
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

##############################
#                            #
#           addons           #
#                            #
##############################


resource "aws_eks_addon" "addon_coredns" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "coredns"

  configuration_values = jsonencode({
    computeType = "fargate"
  })

  depends_on = [ aws_eks_cluster.bye_kevin ]
}

resource "aws_eks_addon" "addon_metrics_server" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "metrics-server"

  depends_on = [ aws_eks_cluster.bye_kevin ]
}

resource "aws_eks_addon" "addon_vpc_cni" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "vpc-cni"

  depends_on = [ aws_eks_cluster.bye_kevin ]
}

resource "aws_eks_addon" "addon_kube_proxy" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "kube-proxy"

  depends_on = [ aws_eks_cluster.bye_kevin ]
}



##############################
#                            #
#          fargate           #
#                            #
##############################

resource "aws_eks_fargate_profile" "bye_kevin_fargate" {
  cluster_name           = aws_eks_cluster.bye_kevin.name
  fargate_profile_name   = "bye-kevin-fargate"
  pod_execution_role_arn = aws_iam_role.bisous_kevin.arn
  subnet_ids             = module.eks.private_subnet_ids

  selector {
    namespace = "default"
  }

  selector {
    namespace = "kube-system"
  }

  tags = {
    Name = "eks-fargate-profile"
  }

  depends_on = [
    aws_iam_role_policy_attachment.role_attachement,
  ]
}

resource "aws_eks_fargate_profile" "bye_kevin_fargate_nginx" {
  cluster_name           = aws_eks_cluster.bye_kevin.name
  fargate_profile_name   = "bye-kevin-fargate-nginx"
  pod_execution_role_arn = aws_iam_role.bisous_kevin.arn
  subnet_ids             = module.eks.private_subnet_ids

  selector {
    namespace = "nginx-app"
  }

  tags = {
    Name = "eks-fargate-profile-nginx"
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



