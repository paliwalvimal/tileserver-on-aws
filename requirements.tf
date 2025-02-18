terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.13.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.26.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.3"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

provider "awscc" {
  alias  = "use1"
  region = "us-east-1"
}
