module "shared" {
  source = "../00-shared"
}

provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    key = "site-cert"
  }
}
