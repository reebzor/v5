terraform {
  backend "s3" {
    bucket = "tomreeb-terraform-state"
    key    = "terraform/prod/dotcom.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 2.0"
}

