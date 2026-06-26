terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ENHANCEMENT: uncomment to store state remotely (recommended for teams)
  # backend "s3" {
  #   bucket         = "your-tfstate-bucket"
  #   key            = "calculator-app/terraform.tfstate"
  #   region         = "ap-south-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-lock"
  # }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "calculator-app"
      ManagedBy   = "Terraform"
      Environment = "dev"
    }
  }
}
