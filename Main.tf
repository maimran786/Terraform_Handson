terraform {
  required_version = ">= 0.12.24"

  backend "s3" {
    bucket = "git-actions-terraform"
    key    = "terraform/state/production.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
