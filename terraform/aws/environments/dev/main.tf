locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }

  azs = ["${var.aws_region}a", "${var.aws_region}b"]
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  vpc_name              = var.vpc_name
  vpc_cidr              = var.vpc_cidr
  availability_zones    = local.azs
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.10.0/24", "10.0.11.0/24"]
  database_subnet_cidrs = ["10.0.20.0/24", "10.0.21.0/24"]
  tags                  = local.common_tags
}

# Kubernetes Module
module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids  = module.networking.public_subnet_ids
  vpc_cidr           = module.networking.vpc_cidr_block
  node_instance_type = var.node_instance_type
  node_count         = var.node_count
  tags               = local.common_tags
}

# PostgreSQL Module
module "postgres" {
  source = "../../modules/postgres"

  postgres_name        = var.postgres_name
  vpc_id               = module.networking.vpc_id
  db_subnet_group_name = module.networking.db_subnet_group_name
  vpc_cidr             = module.networking.vpc_cidr_block
  engine_version       = var.postgres_engine_version
  instance_class       = var.postgres_instance_class
  database_name        = var.database_name
  database_username    = var.database_username
  tags                 = local.common_tags
}

# Traefik Module
module "traefik" {
  source = "../../modules/traefik"

  cluster_name = var.cluster_name
  tags         = local.common_tags
}

#

# Kubernetes Application Manifests
# Deploys the sample application into the cluster
module "app" {
  source = "../../modules/app"

  postgres_host        = module.postgres.endpoint
  postgres_port        = 5432
  postgres_database    = module.postgres.database_name
  postgres_username    = module.postgres.database_username
  postgres_password    = module.postgres.database_password
  secret_arn           = module.postgres.secret_arn
  application_hostname = module.traefik.load_balancer_hostname
  cloud                = "AWS"
  tags                 = local.common_tags
}
