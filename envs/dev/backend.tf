terraform {
  backend "s3" {
    bucket         = "my-org-terraform-state-dev"   
    key            = "ec2-multi/dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-locks-dev"           
    encrypt        = true
  }
}