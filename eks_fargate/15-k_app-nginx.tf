##############################
#                            #
#            NGNX            #
#          namepsace        #
#                            #
##############################
resource "kubernetes_namespace_v1" "nginx_app" {
    metadata {
        name = "nginx-app"
    }

    depends_on = [helm_release.aws_lbc, aws_eks_fargate_profile.bye_kevin_fargate_nginx]
}
##############################
#                            #
#           NGNX             #
#         deployment         #
#                            #
##############################


resource "kubernetes_deployment_v1" "nginx_dpl" {
    metadata {
        name      = "nginx-deployment"
        namespace = kubernetes_namespace_v1.nginx_app.metadata[0].name
        labels = {
            app = "nginx"
        }
    }
    
    spec {
        replicas = 1
    
        selector {
            match_labels = {
                app = "nginx"
            }
        }
    
        template {
            metadata {
                labels = {
                    app = "nginx"
                }
            }
    
            spec {
                container {
                    name  = "nginx"
                    image = "nginx:latest"
            
                    port {
                        container_port = 80
                    }
                    resources {
                        limits = {
                          cpu    = "500m"
                          memory = "1Gi"
                        }
                        requests = {
                          cpu    = "250m"
                          memory = "512Mi"
                        }
                    }
                    liveness_probe {
                        http_get {
                            path = "/"
                            port = 80
                        }

                        initial_delay_seconds = 10
                        period_seconds        = 10
                    }
                    readiness_probe {
                        http_get {
                            path = "/"
                            port = 80
                        }

                        initial_delay_seconds = 5
                        period_seconds        = 5
                    }
                }
            }
        }
    }

    depends_on = [ kubernetes_namespace_v1.nginx_app, aws_eks_addon.addon_metrics_server ]
  
}

##############################
#                            #
#           NGNX             #
#          service           #
#                            #
##############################


resource "kubernetes_service_v1" "example" {
  metadata {
    name = "example"
    namespace = kubernetes_namespace_v1.nginx_app.metadata[0].name
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"                  = "ip"
      "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"                            = "internet-facing"
    }
  }
  spec {
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "nginx"
    }
    type = "LoadBalancer"
  }
  depends_on = [ kubernetes_deployment_v1.nginx_dpl, helm_release.aws_lbc ]
}

##############################
#                            #
#            NGNX            #
#           scaler           #
#                            #
##############################

resource "kubernetes_horizontal_pod_autoscaler_v2" "example" {
  metadata {
    name = "nginx-hpa"
    namespace = kubernetes_namespace_v1.nginx_app.metadata[0].name
  }

  spec {
    min_replicas = 2
    max_replicas = 5

    scale_target_ref {
      kind = "Deployment"
      name = kubernetes_deployment_v1.nginx_dpl.metadata[0].name
      api_version = "apps/v1"
    }

    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = 10
        }
      }
    }

    behavior {
      scale_up {
        stabilization_window_seconds = 0
        select_policy                = "Max"
        policy {
          type           = "Percent"
          value          = 100
          period_seconds = 15
        }
      }
      scale_down {
        stabilization_window_seconds = 30
        select_policy                = "Max"
        policy {
          type           = "Percent"
          value          = 50
          period_seconds = 60
        }
      }
    }
  }

  depends_on = [ kubernetes_deployment_v1.nginx_dpl, aws_eks_addon.addon_metrics_server ]
}