locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  azs = ["${var.aws_region}a", "${var.aws_region}b"]
}

# Networking Module
# Dev runs nodes in public subnets with no NAT gateway to keep cost down.
module "networking" {
  source = "../../modules/networking"

  vpc_name                = var.vpc_name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = local.azs
  public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs    = ["10.0.10.0/24", "10.0.11.0/24"]
  database_subnet_cidrs   = ["10.0.20.0/24", "10.0.21.0/24"]
  enable_nat_gateway      = false
  map_public_ip_on_launch = true
  tags                    = local.common_tags
}

# Kubernetes Module
# EKS cluster sized for Wazuh; Wazuh itself is deployed separately.
module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  node_subnet_ids    = module.networking.public_subnet_ids
  vpc_cidr           = module.networking.vpc_cidr_block
  node_instance_type = var.node_instance_type
  node_capacity_type = var.node_capacity_type
  node_count         = var.node_count
  node_disk_size     = var.node_disk_size
  cluster_log_types  = []
  cluster_admin_arns = var.cluster_admin_arns

  enable_ebs_csi_driver = true

  tags = local.common_tags
}
