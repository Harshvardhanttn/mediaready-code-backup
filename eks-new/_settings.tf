terraform {
  backend "s3" {
    bucket         = ""
    key            = "eks/main.tf"
    region         = ""
    encrypt        = true
  
  }
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

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"  # Path to your kubeconfig file
}
