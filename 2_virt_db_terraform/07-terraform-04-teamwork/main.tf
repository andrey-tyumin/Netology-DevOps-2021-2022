terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

module "ec2-instance" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"
  name                   = "hw74"
  instance_count         = 1
  ami                    = "ami-00399ec92321828f5"
  instance_type          = "t2.micro"
  subnet_id              = "subnet-307a794a"
}
