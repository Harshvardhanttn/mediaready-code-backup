resource "aws_ssm_parameter" "newgen_eks_endpoint" {

  

  name        = "/poc/${var.environment}/eks/endpoint"

  description = "poc-eks-endpoint"

  type        = "String"

  value       = aws_eks_cluster.this.endpoint
}