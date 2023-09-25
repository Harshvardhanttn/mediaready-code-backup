module "create_database" {
  source              = "git::https://github.com/abhishekchauhan98/terraform-aws-rds.git"
  create_rds     = false
  create_aurora = true
  identifier    = "${var.account_name}-${var.project_name}-${var.environment_name}-rds"
  subnet_ids = data.aws_subnets.secure.ids
  vpc_id           = data.aws_vpc.selected.id
  vpc_cidr         = [data.aws_vpc.selected.cidr_block]
  db_subnet_group_id = "${var.project_name}-${var.environment_name}-${var.subnet_group_id}"
  publicly_accessible = false
  #project_name_prefix = "${local.workspace.project_name}-${local.workspace.environment_name}-rds-cluster"
  allocated_storage = var.allocated_storage
  engine = var.engine
  engine_version = var.engine_version
#  db_parameter_group_name=local.workspace["rds"]["parameter_group_name"]
  instance_class = var.instance_class
  database_name = var.db_name
  username   = "root"
  apply_immediately = false
#  storage_encrypted = local.workspace["rds"]["storage_encrypted"]
  kms_key_arn = aws_kms_key.rds_key.arn
  multi_az = false
  deletion_protection = false
  auto_minor_version_upgrade = false
  count_aurora_instances = 1
  serverlessv2_scaling_configuration_max = var.serverlessv2_scaling_configuration_max
  serverlessv2_scaling_configuration_min = var.serverlessv2_scaling_configuration_min
  environment = var.environment_name
  common_tags = {
    "Name"        = "${var.project_name}-rds-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}
resource "aws_kms_key" "rds_key" {
  description             = var.kms_key_desc
  key_usage               = "ENCRYPT_DECRYPT"
  #policy                  = "${data.template_file.kms.rendered}"
  deletion_window_in_days = var.deletion_window_in_days
  is_enabled              = true
  enable_key_rotation     = false

  tags = {
    "Name"        = "${var.project_name}-rds-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/rds-${var.environment_name}-${var.project_name}"
  target_key_id = aws_kms_key.rds_key.id
}
