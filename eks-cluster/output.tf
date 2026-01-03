output "eks_cluster_name" {
    value = aws_eks_cluster.eks_cluster.name
    description = "Name of the EKS cluster"
}

output "eks_node_group_name" {
    value = aws_eks_node_group.eks_node_group.node_group_name
    description = "Name of the EKS node group"
}

output "eks_cluster_endpoint" {
    value = aws_eks_cluster.eks_cluster.endpoint
    description = "Endpoint of the EKS cluster"
}

output "eks_cluster_arn" {
    value = aws_eks_cluster.eks_cluster.arn
    description = "ARN of the EKS cluster"
}

output "eks_cluster_version" {
    value = aws_eks_cluster.eks_cluster.version
    description = "Version of the EKS cluster"
}

output "cluster_certificate_authority" {
    value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    description = "Certificate authority data of the EKS cluster (base64 encoded)"
}

output "cluster_certificate_authority_data" {
    value = base64decode(aws_eks_cluster.eks_cluster.certificate_authority[0].data)
    description = "Certificate authority data of the EKS cluster (decoded)"
}