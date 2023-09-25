# ############################################################################################################
# # EKS CLUSTER
# ############################################################################################################

data "aws_iam_role" "this2" {
  count = var.cluster_role != null ? 1 : 0
  name  = var.cluster_role
}


resource "aws_eks_cluster" "this" {
  name                      = "${var.project_name_prefix}-${var.environment}-cluster"
  role_arn                  = var.cluster_role != null ? data.aws_iam_role.this2[0].arn : aws_iam_role.this[0].arn
  version                   = var.kube_version
  enabled_cluster_log_types = var.logging == true ? ["api", "audit", "authenticator", "controllerManager", "scheduler"] : []

  kubernetes_network_config {
    ip_family         = "ipv4"
    service_ipv4_cidr = var.service_ipv4_cidr
  }
  vpc_config {
    subnet_ids              = var.subnet_ids  
    endpoint_private_access = var.endpoint_private_access == true ? false : true
    endpoint_public_access  = var.endpoint_private_access == true ?  true : false
    security_group_ids      = [for sec in var.security_groups_cluster : aws_security_group.cluster-sg[sec.name].id]
  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
  tags = merge(var.tags, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-cluster",
    "Environment" = "${var.environment}"
  })

}


# ############################################################################################################
# # EKS ADD-ONS
# ############################################################################################################


resource "aws_eks_addon" "this" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "this2" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
  resolve_conflicts = "OVERWRITE"
  depends_on = [
    aws_eks_node_group.this
  ]
}

resource "aws_eks_addon" "this3" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "this4" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "aws-ebs-csi-driver"
  resolve_conflicts = "OVERWRITE"
}




