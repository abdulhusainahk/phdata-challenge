provider "aws" {
  region = "us-east-1"  
  profile = "default"   
}
terraform {
  backend "s3" {
    bucket  = "phdata-terraform-state--use1-az4--x-s3"
    key     = "terraform/phdata-terraform-state/terraform.tfstate"
    profile = "default"
    region  = "us-east-1"
  }
}