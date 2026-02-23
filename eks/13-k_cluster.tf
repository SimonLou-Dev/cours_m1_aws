resource "aws_eks_cluster" "bye_kevin" {
  name = "bye-kevin"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

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
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "bye_kevin_group" {
  cluster_name    = aws_eks_cluster.bye_kevin.name
  node_group_name = "bye-kevin-group"
  node_role_arn   = aws_iam_role.node.arn

  subnet_ids = module.eks.private_subnet_ids

  version = "1.35"

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  launch_template {
    id      = aws_launch_template.bye_kevin_template.id
    version = aws_launch_template.bye_kevin_template.latest_version_number
  }

  remote_access {
    ec2_ssh_key               = aws_key_pair.deployer.key_name
    source_security_group_ids = [aws_security_group.bastion.id]
  }

  instance_types = ["t3.medium"]

  tags = {
    Name = "eks-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_launch_template" "bye_kevin_template" {
  name_prefix   = "bye-kevin-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.medium"

  vpc_security_group_ids = [aws_security_group.node_group.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "eks-node-bye-kevin"
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "EKS node launched"
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "eks-launch-template"
  }
}

