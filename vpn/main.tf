module "vpn" {
  source                           = "git::https://github.com/tothenew/terraform-aws-vpn?ref=v0.0.1"
  create_aws_vpn                   = false
  create_aws_ec2_pritunl           = true
  vpc_id                           = data.aws_vpc.selected.id
  project_name_prefix              = var.environment_name
  key_name                         = var.key_name
  instance_type                    = var.instance_type
  subnet_id                        = data.aws_subnets.public.ids[0]
  volume_type                      = var.volume_type
  root_volume_size                 = var.root_volume_size
  vpn_port                         = var.vpn_port
  common_tags = {
    "Name"        = "${var.project_name}-vpn-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}