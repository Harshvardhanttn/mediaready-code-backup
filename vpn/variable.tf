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
variable "instance_type" {
  type    = string
  default = "t3.medium"
}
variable "volume_type" {
  type    = string
  default = "gp3"
}
variable "root_volume_size" {
  type    = string
  default = "20"
}
variable "vpn_port" {
  type    = string
  default = "15000"
}
variable "key_name" {
  type    = string
  default = "vr-infra"
}
variable "region" {
  type    = string
  default = ""
}