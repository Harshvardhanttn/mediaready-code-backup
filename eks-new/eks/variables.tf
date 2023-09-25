# ############################################################################################################
# # INPUT VARIABLES
# ############################################################################################################
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  description = "Subnets ids that map to eks cluster"
  type        = list(string)
}
# ############################################################################################################
# # EKS cluster variable
# ############################################################################################################

variable "logging" {
  description = "To enable logging in eks cluster"
}

variable "endpoint_private_access" {
  description = "To create eks endpoint private if false then endpoint is public"
  type = bool
}


variable "service_ipv4_cidr" {
  
}
variable "node_role" {
  type    = string
}
variable "kube_version" {
  description = "Kubernetes version that going to used with eks cluster"
}
variable "cluster_role" {
}


#######################################################################################################
                       #  node-group and launch tempate variable 
#######################################################################################################

variable "nodes" {
  description = "List of node groups to launch"
  type        = list(object({
    node_group_name = string
    lt_name         = string
    instance_types  = list(string)
    version         = string
    ebs             = list(object({
      device_name           = string
      delete_on_termination = bool
      encrypted             = bool
      volume_size           = number
      volume_type           = string
    }))
 
    scaling_config = object({
      desired_size    = number
      min_size        = number
      max_size        = number
      max_unavailable = string
    })
  }))
}

variable "node_subnet_ids" {
  description = "To map seprate subnets for nodes"
  type=list(string)
}


variable "ebs_optimized_support" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
}

#######################################################################################################
                         #security group
#######################################################################################################

variable "security_groups_node" {
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      ipv6_cidr_blocks = list(string)
      self             = bool
    }))
    egress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
  }))
  
}

variable "security_groups_cluster" {
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      ipv6_cidr_blocks = list(string)
      self             = bool
    }))
    egress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
  }))
  
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instances"
  type        = list(string)
}

###############################################################################################

#######################################################################################################
                         #tags
#######################################################################################################
variable "vpc_environment" {
  type = string
}

variable "LT_tag" {
  description = "Common tags to apply to launch template"
  type        = map(string)
}

variable "common_tag" {
  description = "Common tags to apply to resources"
  type        = map(string)
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the resources"
}

variable "environment" {
  type        = string
  description = "Used in tags cluster and nodes"
}
variable "project_name_prefix" {
  description = "Used in tags cluster and nodes"
  type = string
}