module "shared" {
  source = "../_shared"
}

provider "aws" {
  region = module.shared.region
}

terraform {
  backend "s3" {
    key = "remote-bucket"
  }
}
