provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region

  default_tags {
    tags = {
      owner = var.owner
    }
  }
}

provider "random" {}

terraform {
  backend "s3" {
    bucket  = "jmorgancusick-terraform-state-sandbox"
    key     = "global/internal-s3-site/terraform.tfstate"
    region  = "us-east-1"
    profile = "personal"

    dynamodb_table = "jmorgancusick-terraform-state-lock-sandbox"
    encrypt        = true
  }
}
