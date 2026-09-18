terraform {
  backend "s3" {
    bucket       = "dev-infra-18sep"
    key          = "terraform/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}