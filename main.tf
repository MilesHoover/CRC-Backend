terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.1"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
  bucket = "mileshoover.com"
  key = "terraform.tfstate"
  region = "us-east-1"
}
}

provider "aws" {
  region  = "us-east-1"
  alias  = "acm_provider"
}