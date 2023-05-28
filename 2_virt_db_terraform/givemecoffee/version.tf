terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
			}   
	}
#  	backend "s3" {
#	bucket = "73backet"
#   		key    = "oki/terraform.tfstate"
#    		region = "us-east-2"
#  	}
}

