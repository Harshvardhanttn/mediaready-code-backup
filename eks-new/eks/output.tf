# ############################################################################################################
# # OUTPUT VARIABLES
# ############################################################################################################

output "endpoint" {
  description = "Return EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "kubeconfig-certificate-authority-data" {
  description = "Return EKS CA cert data"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}


# output "security_groups_cluster" {
#   description = "Return EKS cluster security group"
#   value       = aws_eks_cluster.this.cluster_security_group_id
# }

output "security_groups_node" {
  description = "Return EKS nodegroup security group"
  value       = [for sec in var.security_groups_node : aws_security_group.nodes[sec.name].id]
}


output "eks_cluster_autoscaler_arn" {
  value = aws_iam_role.eks_cluster_autoscaler.arn
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}