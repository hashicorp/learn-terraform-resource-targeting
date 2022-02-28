terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "bucket_name" {
  length    = 3
  separator = "-"
  prefix    = "learning"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "2.14.1"

  bucket = random_pet.bucket_name.id
  acl    = "private"
}

resource "random_pet" "object_names" {
  count = 4

  length    = 5
  separator = "_"
  prefix    = "learning"
}

resource "aws_s3_bucket_object" "objects" {
  count = 4

  acl          = "public-read"
  key          = "${random_pet.object_names[count.index].id}.txt"
  bucket       = module.s3_bucket.s3_bucket_id
  content      = "Example object #${count.index}"
  content_type = "text/plain"
}
