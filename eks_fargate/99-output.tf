output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.bye_kevin.endpoint
}

output "kubeconfig_cmd" {
  description = "Commande pour configurer kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.bye_kevin.name}"
}


output "bastion_ssh" {
  value = "ssh ec2-user@${aws_instance.bastion.public_ip}"
}