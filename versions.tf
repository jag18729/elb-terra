terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  
  # Uncomment this block if you want to use Terraform Cloud
  # backend "remote" {
  #   organization = "YOUR-ORGANIZATION-NAME"
  #   workspaces {
  #     name = "coffee-shop-infrastructure"
  #   }
  # }
}