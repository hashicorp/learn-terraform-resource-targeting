terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28.0"
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
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = random_pet.bucket_name.id
  acl    = "private"
}

module "sns_topic" {
  depends_on = [module.s3_bucket]
  source     = "terraform-aws-modules/sns/aws"

  name  = "my-topic"
}

resource "aws_sns_topic_policy" "default" {
  arn = module.sns_topic.this_sns_topic_arn

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[{
        "Effect": "Allow",
        "Principal": {
            "Service": "s3.amazonaws.com"
        },
        "Action": "SNS:Publish",
        "Resource": "${module.sns_topic.this_sns_topic_arn}",
        "Condition":{
            "ArnLike":{"aws:SourceArn":"${module.s3_bucket.this_s3_bucket_arn}"}
        }
    }]
}
EOF
}

resource "aws_s3_bucket_notification" "notif" {
  bucket = module.s3_bucket.this_s3_bucket_id

  topic {
    topic_arn = module.sns_topic.this_sns_topic_arn

    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*"
    ]
  }
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
  key          = "${random_pet.object_names[count.index].id}.csv"
  bucket       = module.s3_bucket.this_s3_bucket_id
  content      = "first,second,${count.index},last"
  content_type = "text/csv"
}