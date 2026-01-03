terraform {
    required_version = ">= 1.0.0"
    required_providers {
        kubernetes = {
            source = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
    }
}

locals {
    app_label = var.name
}

resource "kubernetes_deployment_v1" "app" {
    metadata {
        name = var.name
    }
    spec {
        replicas = var.replicas
        template {
            metadata{
                labels = {
                    app = var.name
                }
            }
            spec {
                container {
                    name = var.name
                    image = var.image
                    port {
                        container_port = var.container_port
                    }

                    dynamic "env" {
                        for_each = var.environment_variables
                        content {
                            name = env.key
                            value = env.value
                        }
                    }
                }
            }
        }

        selector {
            match_labels = {
                app = local.app_label
            }
        }
    }
}

resource "kubernetes_service_v1" "load_balancer" {
    metadata {
        name = var.name
    }
    spec {
        type = var.service_type
        port {
            port = 80
            target_port = var.container_port
            protocol = "TCP"
        }
        selector = {
            app = local.app_label
        }
    }
    wait_for_load_balancer = var.wait_for_load_balancer
}

data "kubernetes_service_v1" "load_balancer_status" {
    metadata {
        name = var.name
    }
    depends_on = [kubernetes_service_v1.load_balancer]
}