variable "name" {
    description = "The name of the application"
    type = string
    # default = "example-app"
}

variable "image" {
    description = "The image to use for the application"
    type = string
    # default = "nginx:latest"
}

variable "container_port" {
    description = "The port to use for the application"
    type = number
    # default = 80
}

variable "replicas" {
    description = "The number of replicas to use for the application"
    type = number
    # default = 1
}

variable "environment_variables" {
    description = "The environment variables to use for the application"
    type = map(string)
    default = {}
}

variable "service_type" {
    description = "The type of Kubernetes service (ClusterIP, NodePort, LoadBalancer, ExternalName)"
    type = string
    default = "LoadBalancer"
}

variable "wait_for_load_balancer" {
    description = "Whether to wait for LoadBalancer to be ready (set to false for local development)"
    type = bool
    default = true
}