# AWS test Environment Configuration
# Copy this file to terraform.tfvars and adjust values as needed.

aws_region  = "us-east-1"
environment = "test"

# Networking - CHANGE THESE to match your naming convention
vpc_name = "test-vpc"
vpc_cidr = "10.0.0.0/16"

# Kubernetes - CHANGE THESE to match your naming convention
cluster_name       = "test-cluster"
kubernetes_version = "1.34"
node_instance_type = "t3.small"
node_count         = 2

# PostgreSQL - CHANGE THESE to match your naming convention
postgres_name           = "test-postgres"
postgres_instance_class = "db.t3.micro"
postgres_engine_version = "15"
database_name           = "appdb"
database_username       = "dbadmin"

# DNS - CHANGE THIS to your registered domain
domain_name = "app.petclininc.com"

# Project
project_name = "test-infra"
