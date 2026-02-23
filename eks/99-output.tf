output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.bye_kevin.endpoint
}

output "kubeconfig" {
  description = "kubeconfig pour kubectl"
  sensitive   = true
  value = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      name = aws_eks_cluster.bye_kevin.name
      cluster = {
        server                     = aws_eks_cluster.bye_kevin.endpoint
        certificate-authority-data = aws_eks_cluster.bye_kevin.certificate_authority[0].data
      }
    }]
    contexts = [{
      name = aws_eks_cluster.bye_kevin.name
      context = {
        cluster = aws_eks_cluster.bye_kevin.name
        user    = aws_eks_cluster.bye_kevin.name
      }
    }]
    current-context = aws_eks_cluster.bye_kevin.name
    preferences     = {}
    users = [{
      name = aws_eks_cluster.bye_kevin.name
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1beta1"
          command    = "aws"
          args = [
            "eks",
            "get-token",
            "--cluster-name",
            aws_eks_cluster.bye_kevin.name,
          ]
        }
      }
    }]
  })
}


