terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.38.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.1"
    }
  }
  required_version = ">= 1.0"
}
