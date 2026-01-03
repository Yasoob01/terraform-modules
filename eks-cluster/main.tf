
data "aws_iam_policy_document" "eks_cluster_policy_document" {
    statement {
        actions = ["sts:AssumeRole"]
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["eks.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.cluster_name}-role"
    assume_role_policy = data.aws_iam_policy_document.eks_cluster_policy_document.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
    role = aws_iam_role.eks_cluster_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


#for node group
data "aws_iam_policy_document" "eks_node_group_policy_document" {
    statement {
        actions = ["sts:AssumeRole"]
        effect = "Allow"
        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "eks_node_group_role" {
    name = "${var.cluster_name}-node-group-role"
    assume_role_policy = data.aws_iam_policy_document.eks_node_group_policy_document.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCNIPolicy" {
    role = aws_iam_role.eks_node_group_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


############ EKS Cluster ############
resource "aws_eks_cluster" "eks_cluster" {
    name = var.cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn
    vpc_config {
        subnet_ids = var.subnet_ids
    }

    depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy_attachment]
}

############ EKS Node Group ############
resource "aws_eks_node_group" "eks_node_group" {
    cluster_name = aws_eks_cluster.eks_cluster.name
    node_group_name = "${var.cluster_name}-node-group"
    node_role_arn = aws_iam_role.eks_node_group_role.arn
    subnet_ids = var.subnet_ids
    instance_types = var.instance_types
    scaling_config {
        desired_size = var.desired_size
        max_size = var.max_size
        min_size = var.min_size
    }

    depends_on = [aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
                  aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
                  aws_iam_role_policy_attachment.AmazonEKSCNIPolicy]
}
