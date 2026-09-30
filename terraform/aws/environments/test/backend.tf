terraform {
  backend "s3" {
    bucket = "dev-infra-18sep"
    key    = "terraform/aws/test/terraform.tfstate"
    region = "us-east-1"
  }
}