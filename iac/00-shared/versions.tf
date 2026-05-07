terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.44.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.5"
    }
  }
  required_version = ">= 1.15.2"
}
