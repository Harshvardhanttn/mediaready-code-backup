module "message_queue" {
  source              = "git::https://github.com/abhishekchauhan98/terraform-aws-queue.git"
  create_aws_activemq     = false
  create_aws_ec2_rabbitmq = true
  vpc_id  = data.aws_vpc.selected.id
  ec2_subnet_id =  data.aws_subnets.private.ids[0]
  subnet_ids = data.aws_subnets.private.ids
  worker  = 0
  master  = 1
  key_name = var.key_name
  kms_key_id = aws_kms_key.queue_key.arn
  instance_type = var.instance_type
  disable_api_termination = true
  disable_api_stop        = false
  root_volume_size = 50
  vpc_cidr_block = "172.31.0.0/16"
  environment_name = var.environment_name
  region = var.region
  project_name_prefix = "mediaready"
  common_tags = {
    "Name"        = "${var.project_name}-rabbitmq-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}
resource "aws_kms_key" "queue_key" {
  description             = var.kms_key_desc
  key_usage               = "ENCRYPT_DECRYPT"
  #policy                  = "${data.template_file.kms.rendered}"
  deletion_window_in_days = var.deletion_window_in_days
  is_enabled              = true
  enable_key_rotation     = false

  tags = {
    "Name"        = "${var.project_name}-rabbitmq-${var.environment_name}"
    "Project"     = var.project_name
    "Environment" = var.environment_name
    "Owner"       = var.owner
  }
}

resource "aws_kms_alias" "queue_key_alias" {
  name          = "alias/queue-${var.environment_name}-${var.project_name}"
  target_key_id = aws_kms_key.queue_key.id
}