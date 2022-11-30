terraform {
  /* Uncomment this block to use Terraform Cloud for this tutorial
  cloud {
      organization = "hashicorp-support-org"
      workspaces {
        name = "zisom-learn-terraform-resource-targeting"
      }
  }
  */

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  required_version = "~> 1.2.0"
}

