terraform {
  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = "~> 6.28.0"
    }
    kubernetes = {
      source  = "opentofu/kubernetes"
      version = "~> 3.0.1"
    }
    helm = {
      source  = "opentofu/helm"
      version = "~> 3.1.1"
    }
    http = {
      source  = "opentofu/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = aws_eks_cluster.bye_kevin.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.bye_kevin.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.bye_kevin.name]
  }
}

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.bye_kevin.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.bye_kevin.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.bye_kevin.name]
    }
  }
}