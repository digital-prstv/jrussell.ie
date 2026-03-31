terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.61"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.5"
    }
  }
  required_version = ">= 1.0"
}
