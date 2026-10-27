terraform {
  backend "s3" {
    bucket       = "infra-setup-tfstate-731372490312"
    key          = "terraform/aws/test/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
