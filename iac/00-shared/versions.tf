terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.45.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.4.0"
    }
  }
  required_version = ">= 1.15.4"
}
