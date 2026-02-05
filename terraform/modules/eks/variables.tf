variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_role_arn" {
  description = "ARN of IAM role for EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of IAM role for EKS node group"
  type        = string
}

variable "nodegroup_subnet_ids" {
  description = "Subnets for EKS cluster and node group"
  type        = list(string)
}
