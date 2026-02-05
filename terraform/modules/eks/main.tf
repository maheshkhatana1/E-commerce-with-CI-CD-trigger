# KMS KEY (TOP-LEVEL)
resource "aws_kms_key" "this" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 10
}
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "ecommerce-node-group"
  node_role_arn  = var.node_role_arn
  subnet_ids = var.nodegroup_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t3.micro"]

  depends_on = [
    aws_eks_cluster.this,
  ]
}




# EKS CLUSTER
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids = var.nodegroup_subnet_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.this.arn
    }
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]


   lifecycle {
    ignore_changes = [
      bootstrap_self_managed_addons,
      encryption_config,
      vpc_config[0].subnet_ids,
      kubernetes_network_config,
      access_config,
      upgrade_policy
    ]
  }
}
