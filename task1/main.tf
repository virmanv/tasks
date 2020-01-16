terraform {
  required_version = ">= 0.10.3" 
}
provider "aws" {
  region  = "ap-southeast-2"
  version = ">= 2.38.0"
}
data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

