variable "cluster_name" {
    description = "The name of the EKS cluster"
    type        = string
}

variable "min_size" {
    description = "The minimum size of the EKS node group"
    type        = number
}

variable "max_size" {
    description = "The maximum size of the EKS node group"
    type        = number
}

variable "desired_size" {
    description = "The desired size of the EKS node group"
    type        = number
}

variable "instance_types" {
    description = "The EC2 instance types of the EKS cluster"
    type        = list(string)
}

variable "subnet_ids" {
    description = "The subnet IDs of the EKS cluster"
    type        = list(string)
}

variable "vpc_id" {
    description = "The VPC ID of the EKS cluster"
    type        = string
}

variable "tags" { 
    description = "The tags of the EKS cluster"
    type        = map(string)
}