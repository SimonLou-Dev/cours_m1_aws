##############################
#                            #
#          AWS LBC           #
#       OIDC Provider        #
#                            #
##############################

# En gros Service account pour AWS, fait le lien entre AWS et kube
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []
  url             = aws_eks_cluster.bye_kevin.identity[0].oidc[0].issuer

  depends_on = [aws_eks_cluster.bye_kevin]
}


##############################
#                            #
#           AWS LBC          #
#             IAM            #
#                            #
##############################

# Création d'une policy IAM pour le AWS LBC
data "http" "lbc_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.11.0/docs/install/iam_policy.json"
}

# Création d'un rôle IAM pour le AWS LBC
resource "aws_iam_policy" "aws_lbc" {
  name   = "AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.lbc_iam_policy.response_body
}

# Création d'un rôle IAM pour le AWS LBC
resource "aws_iam_role" "aws_lbc" {
  name = "eks-aws-lbc"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

# Attachement de la policy au rôle
resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}


##############################
#                            #
#           AWS LBC          #
#        Helm Release        #
#                            #
##############################

# Installation du AWS LBC via Helm
resource "helm_release" "aws_lbc" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version         = "1.11.0"
  cleanup_on_fail = true

  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.bye_kevin.name
      type  = "auto"
    },
    {
      name  = "serviceAccount.create"
      value = "true"
      type  = "auto"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
      type  = "auto"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.aws_lbc.arn
      type  = "auto"
    },
    {
      name  = "region"
      value = var.region
      type  = "auto"
    },
    {
      name  = "vpcId"
      value = module.eks.vpc_id
      type  = "auto"
    },
  ]

  depends_on = [
    aws_eks_cluster.bye_kevin,
    aws_eks_node_group.bye_kevin_group,
    aws_iam_role_policy_attachment.aws_lbc,
    aws_eks_addon.addon_vpc_cni,
    aws_eks_addon.addon_kube_proxy,
  ]
}

