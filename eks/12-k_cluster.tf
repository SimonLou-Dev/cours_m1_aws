resource "aws_eks_cluster" "bye_kevin" {
  name = "bye-kevin"

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = module.eks.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "bye_kevin_group" {
  cluster_name    = aws_eks_cluster.bye_kevin.name
  node_group_name = "bye-kevin-group"
  node_role_arn   = aws_iam_role.cluster.arn

  subnet_ids = module.eks.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = aws_key_pair.deployer.key_name
  }
}


resource "aws_launch_template" "bye_kevin_template" {
  name_prefix = "bye-kevin"
  image_id    = data.aws_ami.amazon_linux.id # Specify your desired AMI ID
  instance_type = "t3.medium"  # Specify your desired instance type
  key_name    = aws_key_pair.deployer.key_name   # Specify your SSH keypair
}
