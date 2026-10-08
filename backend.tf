terraform {
  backend "s3" {
    bucket = "my-terraform-state-202610071118"
    key    = "aws-lab/terraform.tfstate"
    region = "ap-northeast-2"
  }
}