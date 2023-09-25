#################################################################################################
#VPC & SUBNETS
#################################################################################################

vpc_id         = "vpc-092ae5c7a69b7f41c"

app-subnet_ids = ["subnet-09994e7e570e1b1a9","subnet-0ee5499dc09c41b2b","subnet-0fa93c66a59572e92","subnet-03225ae96953ae57e"]
# 
###############################################################################################
# EKS #

endpoint                              = aws_eks_cluster.this.endpoint
kubeconfig-certificate-authority-data = aws_eks_cluster.this.certificate_authority[0].data
#subnet_ids                            = ["subnet-042869d84827c5368", "subnet-09fc7ac020494e9b8", "subnet-0a9757760ecc4be75"]
logging                 = true

endpoint_private_access = true
#ami_type                = null
service_ipv4_cidr       = null

###############################################################################################
# Node Group #

node_role              = null
vpc_security_group_ids = []
ebs_optimized_support  = false
kube_version           = "1.27"
cluster_role           = null

################################################################################################
# Nodes #

nodes = [{
  node_group_name = "etv-dev-node"
  lt_name         = "etv-dev-lt"
  instance_types  = ["m5.xlarge"]
  version         = "$Latest"
  ebs = [{
    device_name           = "/dev/xvda"
    delete_on_termination = true
    encrypted             = true
    volume_size           = 30
    volume_type           = "gp3"
  }]
  scaling_config = {
    desired_size    = 3
    min_size        = 3
    max_size        = 10
    max_unavailable = 1
  }
}]
security_groups_node = [{
  name        = "etv-dev-node-security-group"
  description = "Inbound & Outbound traffic for node-security-group"
  ingress = [
    {
      description      = "Allow traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      # cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      self             = true
    },
  ]
  egress = [
    {
      description      = "Allow all outbound traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}]
vpc_environment = "dev"

security_groups_cluster = [{
  name        = "etv-dev-custom-security-group"
  description = "Inbound & Outbound traffic for cluster-security-group"
  ingress = [
    {
      description      = "All traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      ipv6_cidr_blocks = null
      self             = true
    }
  ]
  egress = [
    {
      description      = "Allow all outbound traffic"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  ]
}]

###################################################################################################
#  common tags #

common_tag = {
  Project   = "etv",
  ManagedBy = "TTN"
}

tags        = null
Environment = "dev"


LT_tag = {
  AMI = null
}
project_name_prefix = "etv"