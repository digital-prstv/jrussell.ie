module "shared" {
  source = "../00-shared"
}

provider "aws" {
  region = module.shared.region
}

terraform {
  backend "s3" {
    key = "network"
  }
}
