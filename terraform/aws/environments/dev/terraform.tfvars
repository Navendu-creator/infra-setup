# AWS Dev Environment Configuration
# EKS infrastructure for Wazuh (Wazuh itself is deployed separately).

aws_region  = "us-east-1"
environment = "dev"

# Networking - CHANGE THESE to match your naming convention
vpc_name = "dev-vpc"
vpc_cidr = "10.0.0.0/16"

# Kubernetes - CHANGE THESE to match your naming convention
cluster_name       = "dev-cluster"
kubernetes_version = "1.34"
node_instance_type = "m7i-flex.large"
node_capacity_type = "ON_DEMAND"
node_count         = 2
node_disk_size     = 30

# Who gets kubectl admin on the cluster. List both your own IAM user and the
# IAM user whose keys are in GitHub secrets, otherwise each apply locks the other out.
cluster_admin_arns = [
  "arn:aws:iam::731372490312:user/Navendu",
  # "arn:aws:iam::731372490312:user/<github-actions-user>", # add if CI uses a different IAM user
]

# Project
project_name = "dev-infra"
