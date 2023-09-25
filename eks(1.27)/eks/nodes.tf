# ############################################################################################################
# # Data block for custom ami
# ############################################################################################################
data "aws_ami" "this" {
  #count       = var.ami_type == null ? 1 : 0
  owners      = ["602401143452"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kube_version}*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}




#locals {
#  ami_type = var.ami_type != null ? var.ami_type : data.aws_ami.this[0].id
#}


# ############################################################################################################
# # NODE GROUPS
# ############################################################################################################

data "aws_iam_role" "this" {
  count = var.node_role != null ? 1 : 0
  name  = var.node_role
}

resource "aws_eks_node_group" "this" {
  for_each        = { for vm in var.nodes : vm.node_group_name => vm }
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.node_group_name
  node_role_arn   = var.node_role != null ? data.aws_iam_role.this[0].arn : aws_iam_role.this3[0].arn
  subnet_ids      = var.node_subnet_ids != null ? var.node_subnet_ids : var.subnet_ids

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = each.value.version
  }

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config { max_unavailable = each.value.scaling_config.max_unavailable }

  tags = merge(var.tags, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-node-group",
    "Environment" = "${var.environment}"
    "AMI"        = "NA" 
  })
  

  depends_on = [
    aws_eks_cluster.this,
    aws_launch_template.this
  ]
}

# ############################################################################################################
# # LAUNCH TEMPLATE
# ############################################################################################################


resource "aws_launch_template" "this" {
  for_each = { for vm in var.nodes : vm.node_group_name => vm }
  name     = each.value.lt_name
  instance_type = each.value.instance_types[0]
  key_name = "terraform-basic"
  #image_id      = "$[data.aws_ami.this]"
  image_id = data.aws_ami.this.id
  ebs_optimized = var.ebs_optimized_support
  update_default_version = true
  vpc_security_group_ids =  [for sec in var.security_groups_node : aws_security_group.nodes[sec.name].id]
   

  dynamic "block_device_mappings" {
    for_each = [for volume in each.value.ebs : {
      device_name           = lookup(volume, "device_name", null)
      delete_on_termination = lookup(volume, "delete_on_termination", null)
      encrypted             = lookup(volume, "encrypted", null)
      volume_size           = lookup(volume, "volume_size", null)
      volume_type           = lookup(volume, "volume_type", null)
     }]
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
      }
    }
  }
 

  tags = merge(var.LT_tag, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-launch-template",
    "Environment" = "${var.environment}"
    "AMI"        = "NA" 
  })
  user_data = base64encode(templatefile("${path.module}/userdata/startup_script.tpl", {
    CLUSTER-ENDPOINT           = aws_eks_cluster.this.endpoint
    CLUSTER_NAME               = aws_eks_cluster.this.name
    CERTIFICATE_AUTHORITY_DATA = aws_eks_cluster.this.certificate_authority[0].data
  }))

  depends_on = [
    aws_eks_cluster.this,
  ]
tag_specifications {
    resource_type = "volume"
    
    tags = merge(var.LT_tag, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-launch-template",
    "Environment" = "${var.environment}"
    "AMI"        = "NA" 
  })
    }
  tag_specifications {
    resource_type = "instance"
    
    tags = merge(var.LT_tag, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-launch-template",
    "Environment" = "${var.environment}"
    "AMI"        = "NA" 
  })
    }
  
  tag_specifications {
    resource_type = "network-interface"
    
    tags = merge(var.LT_tag, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-launch-template",
    "Environment" = "${var.environment}"
    "AMI"        = "NA" 
  })
    }
    }