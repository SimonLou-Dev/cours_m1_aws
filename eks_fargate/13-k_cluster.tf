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

  depends_on = [aws_eks_node_group.bye_kevin_group]
}

resource "aws_eks_addon" "addon_metrics_server" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "metrics-server"

  depends_on = [aws_eks_node_group.bye_kevin_group]
}

resource "aws_eks_addon" "addon_vpc_cni" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "vpc-cni"

  depends_on = [ aws_eks_node_group.bye_kevin_group]
}

resource "aws_eks_addon" "addon_kube_proxy" {
  cluster_name = aws_eks_cluster.bye_kevin.name
  addon_name   = "kube-proxy"

  depends_on = [ aws_eks_node_group.bye_kevin_group ]
}

##############################
#                            #
#         node group         #
#                            #
##############################

resource "aws_eks_node_group" "bye_kevin_group" {
  cluster_name    = aws_eks_cluster.bye_kevin.name
  node_group_name = "bye-kevin-group-standard"
  node_role_arn   = aws_iam_role.bisous_kevin.arn

  subnet_ids = module.eks.private_subnet_ids

  scaling_config {
    desired_size = 5
    max_size     = 6
    min_size     = 3
  }

  launch_template {
    id      = aws_launch_template.bye_kevin_template.id
    version = aws_launch_template.bye_kevin_template.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  tags = {
    Name = "eks-ng-bye-kevin-standard"
  }

  depends_on = [
    aws_iam_role_policy_attachment.role_attachement,
  ]
}

resource "aws_launch_template" "bye_kevin_template" {
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.fargate_sg.id,
    aws_eks_cluster.bye_kevin.vpc_config[0].cluster_security_group_id,
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "eks-node-bye-kevin-standard"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "eks-launch-template"
  }
}


##############################
#                            #
#          fargate           #
#                            #
##############################

resource "aws_eks_fargate_profile" "bye_kevin_fargate_nginx" {
  cluster_name           = aws_eks_cluster.bye_kevin.name
  fargate_profile_name   = "bye-kevin-fargate-nginx"
  pod_execution_role_arn = aws_iam_role.fargate_pod_execution.arn
  subnet_ids             = module.eks.private_subnet_ids

  selector {
    namespace = "nginx-app"
  }

  tags = {
    Name = "eks-fargate-profile-nginx"
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate_pod_execution,
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



