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

output "nlb_hostname" {
  description = "Hostname du NLB nginx (peut prendre quelques minutes à être disponible)"
  value       = try(kubernetes_service_v1.example.status[0].load_balancer[0].ingress[0].hostname, "en attente...")
}

output "nginx_url" {
  description = "URL d'accès à nginx"
  value       = try("http://${kubernetes_service_v1.example.status[0].load_balancer[0].ingress[0].hostname}", "en attente...")
}
