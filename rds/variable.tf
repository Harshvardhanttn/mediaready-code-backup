variable "environment_name" {
  type    = string
  default = "dev"
}
variable "project_name" {
  type    = string
  default = "mediaready"
}
variable "owner" {
  type    = string
  default = "harsh.vardhan@tothenew.com"
}
variable "allocated_storage" {
  type    = string
  default = "100"
}
variable "engine" {
  type    = string
  default = "aurora-mysql"
}
variable "engine_version" {
  type    = string
  default = "8.0.mysql_aurora.3.02.0"
}
variable "instance_class" {
  type    = string
  default = "db.serverless"
}
variable "db_name" {
  type    = string
  default = "mr_db"
}
variable "serverlessv2_scaling_configuration_max" {
  type    = string
  default = "10"
}
variable "serverlessv2_scaling_configuration_min" {
  type    = string
  default = "4"
}
variable "kms_key_desc" {
  type    = string
  default = "key for rds"
}
variable "deletion_window_in_days" {
  type    = string
  default = "7"
}
variable "account_name" {
  type    = string
  default = "mr"
}
variable "Owner" {
  type    = string
  default = "harsh.vardhan@tothenew.com"
}
variable "subnet_group_id" {
  type    = string
  default = "subnet_group"
}
variable "region" {
  type    = string
  default = ""
}