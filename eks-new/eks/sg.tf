# ############################################################################################################
# # Security Groups For nodes-group
# ############################################################################################################

resource "aws_security_group" "nodes" {
  vpc_id   = var.vpc_id
  name     = "${var.project_name_prefix}-${var.environment}-nodes-SG"
  for_each = { for sec in var.security_groups_node : sec.name => sec }
  dynamic "ingress" {
    for_each = try(each.value.ingress, [])
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      self            =  try(ingress.value.self, true)
      security_groups = [for sec in var.security_groups_cluster : aws_security_group.cluster-sg[sec.name].id]
    }
  }

  dynamic "egress" {
    for_each = try(each.value.egress, [])
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    
    }
  }

tags = merge(var.tags, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-sg",
    "Environment" = "${var.environment}"
  })
}


# ############################################################################################################
# # Security Groups For cluster
##############################################################################################################

resource "aws_security_group" "cluster-sg" {
  vpc_id   = var.vpc_id
  name     = "${var.project_name_prefix}-${var.environment}-Cluster-SG"
  for_each = { for sec in var.security_groups_cluster : sec.name => sec }
  dynamic "ingress" {
    for_each = try(each.value.ingress, [])
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
      self            =  try(ingress.value.self, true)
    }
  }

  dynamic "egress" {
    for_each = try(each.value.egress, [])
    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

tags = merge(var.tags, var.common_tag , {
    "Name"        = "${var.project_name_prefix}-${var.environment}-sg",
    "Environment" = "${var.environment}"
  })
}
######################################################################################################
#                                  RULE ADD TO exEsting SG
######################################################################################################

resource "aws_security_group_rule" "cluster_rule_sg_add" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id = element([aws_security_group.cluster-sg[var.security_groups_cluster[0].name].id], 0)
  source_security_group_id = element([aws_security_group.nodes[var.security_groups_node[0].name].id],0)

}