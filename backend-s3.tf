terraform {
  backend "s3" {
    bucket = "elafkaihi-teraform-remote-state"
    key    = "terraform/backend"
    region = "us-east-1"
  }
}