output "service_endpoint" {
    value = try("http://${data.kubernetes_service_v1.load_balancer_status.status[0].load_balancer[0].ingress[0].hostname}", "error getting service endpoint")
    description = "Endpoint of the service"
}