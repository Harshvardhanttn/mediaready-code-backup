# ############################################################################################################
# # IAM ROLE FOR EKS CLUSTER
# ############################################################################################################

resource "aws_iam_role" "this" {
  count = var.cluster_role != null ? 0 : 1
  name = "eks-poc-cluster-role"

  assume_role_policy = <<POLICY
{
"Version": "2012-10-17",
"Statement": [
    {
    "Effect": "Allow",
    "Principal": {
        "Service": "eks.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
    }
]
}
POLICY
}

# ############################################################################################################
# # POLICIES ATTACH TO ROLE
# ############################################################################################################

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  count = var.cluster_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  count = var.cluster_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.this[0].name
}



# ###########################################
# # FETCHING CERT
# ###########################################

data "tls_certificate" "this" {
  count = var.cluster_role != null ? 0 : 1
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# ###########################################
# # CREATING IAM CONNECTOR
# ###########################################

resource "aws_iam_openid_connect_provider" "this" {
  count = var.cluster_role != null ? 0 : 1
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

# ###########################################
# # CREATING POLICY  
# ###########################################

data "aws_iam_policy_document" "this" {
  count = var.cluster_role != null ? 0 : 1
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this[0].arn]
      type        = "Federated"
    }
  }
}

# ###########################################
# # CREATING ROLE WITH ATTACHED POLICY 
# ###########################################

resource "aws_iam_role" "this2" {
  count = var.cluster_role != null ? 0 : 1
  assume_role_policy = data.aws_iam_policy_document.this[0].json
  name               = "iam_service_account_role_for_eks"
}






# ############################################################################################################
# # IAM ROLES FOR NODE GROUPS
# ############################################################################################################


resource "aws_iam_role" "this3" {
  count = var.node_role != null ? 0 : 1
  name = "eks-poc-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "ElasticLoadBalancingFullAccess" {
  count = var.node_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
  role       = aws_iam_role.this3[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  count = var.node_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this3[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  count = var.node_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this3[0].name
}
resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  count = var.node_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this3[0].name
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  count = var.node_role != null ? 0 : 1
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.this3[0].name
}

# ############################################################################################################
# # INSTANCE PROFILE FOR ASG LAUNCH TEMPLATE
# ############################################################################################################

resource "aws_iam_instance_profile" "this" {
 name = "${aws_eks_cluster.this.name}-instance_profile"
 role = var.node_role !=null ? var.node_role : aws_iam_role.this3[0].name
 tags = merge(var.tags, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}",
    "Environment" = "${var.environment}"
  })
}


########################## CSA ###############################

data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cluster_autoscaler" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
  name               = "eks-cluster-autoscaler"
}

resource "aws_iam_policy" "eks_cluster_autoscaler" {
  name = "eks-cluster-autoscaler"

  policy = jsonencode({
    Statement = [{
      Action = [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ]
      Effect   = "Allow"
      Resource = "*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_autoscaler_attach" {
  #policy_arn = "arn:aws:iam::aws:policy/eks_cluster_autoscaler"
  policy_arn = aws_iam_policy.eks_cluster_autoscaler.arn
  role       = aws_iam_role.eks_cluster_autoscaler.name
}


######################## iam controller #################################

data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this[0].url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this[0].arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}

resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("./AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
  role       = aws_iam_role.aws_load_balancer_controller.name
}
