# IAM role for EKS cluster
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM role for EKS node group
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "node_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Security group for EKS cluster
resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-sg"
  })
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = false
  }
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.cluster.id]
  }

  enabled_cluster_log_types = var.cluster_log_types

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
  ]

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

# EKS Node Group
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.node_subnet_ids != null ? var.node_subnet_ids : var.private_subnet_ids

  instance_types = [var.node_instance_type]
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.node_count
    min_size     = var.node_count
    max_size     = var.node_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy,
    aws_iam_role_policy_attachment.node_cni_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
  ]

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-node-group"
  })
}

locals {
  # Explicit admin list keeps local users and CI from replacing each other's access.
  admin_arns = length(var.cluster_admin_arns) > 0 ? var.cluster_admin_arns : [data.aws_caller_identity.current.arn]
}

# EKS access entries for cluster admins (so terraform / kubectl can manage k8s resources)
resource "aws_eks_access_entry" "this" {
  count         = length(local.admin_arns)
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.admin_arns[count.index]
  type          = "STANDARD"
  tags = merge(var.tags, {
    ManagedBy = "terraform"
  })
}

resource "aws_eks_access_policy_association" "this" {
  count         = length(local.admin_arns)
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.admin_arns[count.index]
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
  depends_on = [
    aws_eks_access_entry.this,
  ]
}

moved {
  from = aws_eks_access_entry.this
  to   = aws_eks_access_entry.this[0]
}

moved {
  from = aws_eks_access_policy_association.this
  to   = aws_eks_access_policy_association.this[0]
}

resource "time_sleep" "wait_for_access_propagation" {
  create_duration = "30s"
  depends_on      = [aws_eks_access_policy_association.this]
}

# EBS CSI driver: needed for PersistentVolumes (e.g. Wazuh indexer/manager StatefulSets)
resource "aws_eks_addon" "pod_identity_agent" {
  count        = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"

  depends_on = [aws_eks_node_group.this]

  tags = var.tags
}

resource "aws_iam_role" "ebs_csi" {
  count = var.enable_ebs_csi_driver ? 1 : 0
  name  = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  count      = var.enable_ebs_csi_driver ? 1 : 0
  role       = aws_iam_role.ebs_csi[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  count           = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi[0].arn

  tags = var.tags
}

resource "aws_eks_addon" "ebs_csi" {
  count        = var.enable_ebs_csi_driver ? 1 : 0
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"

  # Creates a default gp3 StorageClass ("ebs-csi-default-sc")
  configuration_values = jsonencode({
    defaultStorageClass = { enabled = true }
  })

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.ebs_csi,
    aws_iam_role_policy_attachment.ebs_csi,
  ]

  tags = var.tags
}

# VPC CNI as a managed add-on, so its config is in code. Network policy
# enforcement is off in the default install; without it NetworkPolicies are
# silently ignored.
resource "aws_eks_addon" "vpc_cni" {
  count        = var.enable_network_policy ? 1 : 0
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"

  # Take over the self-managed aws-node DaemonSet EKS installed at creation.
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = jsonencode({
    enableNetworkPolicy = "true"
  })

  # The add-on only reports ACTIVE once aws-node pods are running on nodes.
  depends_on = [aws_eks_node_group.this]

  tags = var.tags
}

# AWS Load Balancer Controller: IAM only. The controller itself is a Helm
# chart deployed by Argo CD, with service account kube-system/aws-load-balancer-controller.
resource "aws_iam_policy" "lb_controller" {
  count       = var.enable_lb_controller_iam ? 1 : 0
  name        = "${var.cluster_name}-lb-controller"
  description = "AWS Load Balancer Controller for ${var.cluster_name}"
  # Upstream docs/install/iam_policy.json; refresh it when bumping the controller's major/minor version.
  policy = file("${path.module}/lb-controller-iam-policy.json")

  tags = var.tags
}

resource "aws_iam_role" "lb_controller" {
  count = var.enable_lb_controller_iam ? 1 : 0
  name  = "${var.cluster_name}-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lb_controller" {
  count      = var.enable_lb_controller_iam ? 1 : 0
  role       = aws_iam_role.lb_controller[0].name
  policy_arn = aws_iam_policy.lb_controller[0].arn
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  count           = var.enable_lb_controller_iam ? 1 : 0
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller[0].arn

  # The Pod Identity agent hands out the credentials.
  depends_on = [aws_eks_addon.pod_identity_agent]

  tags = var.tags
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
