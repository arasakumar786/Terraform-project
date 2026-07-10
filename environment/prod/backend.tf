terraform {
  backend "s3" {
    bucket       = "infra-deployment-terraform-state-trensstore"
    key          = "prod/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true

  }
}