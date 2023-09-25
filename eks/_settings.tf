terraform {
  backend "s3" {
    bucket         = ""
    key            = "eks/main.tf"
    region         = ""
    encrypt        = true
  
  }
}

provider "aws" {
  region  = local.workspace["aws"]["region"]
}

terraform {
  required_version = ">= 1.3.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "4.23.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.10.0"
    }
    mysql = {
      source = "petoju/mysql"
      version = "3.0.27"
    }
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
      version = "1.7.0"
    }
  }
}

locals {
  env_space = yamldecode(file("${path.module}/config-${terraform.workspace}.yml"))
  workspace = local.env_space["workspaces"][terraform.workspace]

  project_name_prefix = "${local.workspace.environment_name}-${local.workspace.project_name}"

  tags = {
    Project     = local.workspace.project_name
    Environment = local.workspace.environment_name
  }
}