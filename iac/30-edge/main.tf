module "shared" {
  source = "../00-shared"
}

provider "aws" {
  alias  = "eu"
  region = module.shared.region
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    key = "edge"
  }
}
