variable "key_name" {
  type    = string
  default = "vr-infra"
}
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "region" {
  type    = string
  default = ""
}
variable "kms_key_desc" {
  type    = string
  default = "key for queue"
}
variable "deletion_window_in_days" {
  type    = string
  default = "7"
}
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
variable "queue_list" {
  type    = list(string)
  default = ["search-new","search-mr"]
}
variable "exchange_list" {
  type    = list(string)
  default = ["search-exchange","search-mr","search-new"]
}
