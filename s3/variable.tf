variable "s3_bucket" {
  type    = string
  default = "ttn-mediaready"
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
variable "region" {
  type    = string
  default = ""
}