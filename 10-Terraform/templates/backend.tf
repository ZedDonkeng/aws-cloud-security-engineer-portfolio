terraform {
  backend "s3" {
    bucket         = "my-tf-state-<ACCOUNT_ID>"
    key            = "portfolio/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-lock"
    encrypt        = true
  }
}
