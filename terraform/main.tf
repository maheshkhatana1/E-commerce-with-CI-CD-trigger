module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = "ecommerce-app"
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source              = "./modules/eks"
  cluster_name        = var.cluster_name
  cluster_role_arn    = module.iam.cluster_role_arn
  node_role_arn       = module.iam.node_role_arn
  nodegroup_subnet_ids = module.vpc.private_subnet_ids
}



