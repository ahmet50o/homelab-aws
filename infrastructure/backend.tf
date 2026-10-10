terraform {
  backend "s3" {
    bucket = "my-homelab-tfstate-ahmoe"
    key    = "homelab/terraform.tfstate"
    region = "eu-central-1"
  }
}
