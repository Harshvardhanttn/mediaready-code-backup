terraform {
  backend "s3" {
    bucket         = ""
    key            = "cloudfront/main.tf"
    region         = ""
    encrypt        = true
  
  }
}

provider "aws" {
  region  = var.region
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