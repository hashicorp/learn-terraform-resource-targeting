# Learn Terraform Resource Targeting

Learn what Terraform resource targeting is and how to use it.

Follow along with the [Learn guide](#FIXME) at HashiCorp Learn.

This repository implements a VPC, load balancer, and EC2 instances in an example web app configuration.

# Steps

1. Check out config: `git clone git@github.com:hashicorp/learn-terraform-resource-targeting.git` or `git clone https://github.com/hashicorp/learn-terraform-resource-targeting.git`
1. Initialize the config: `terraform init`
1. Apply the config: `terraform apply`
1. Observe the outputs - bucket_name and bucket_arn
1. In `main.tf`, update `random_pet.bucket_name` to be length 5.
```diff
-   length    = 3
+   length    = 5
```
1. Plan this change: `terraform plan`
1. Observe that changing the name will replace several resources (the bucket name, bucket, bucket objects, and bucket notification), and update one in place (the SNS topic policy)
```
Plan: 8 to add, 1 to change, 8 to destroy.
```
1. Also observe that you won't know the new bucket name until the change is applied.
```text
  # random_pet.bucket_name must be replaced
-/+ resource "random_pet" "bucket_name" {
      ~ id        = "learning-early-immune-wombat" -> (known after apply)
      ~ length    = 3 -> 5 # forces replacement
        # (2 unchanged attributes hidden)
    }
```
1. Apply the change, but only target the bucket name: `terraform apply -target=random_pet.bucket_name`.
```
  # random_pet.bucket_name must be replaced
-/+ resource "random_pet" "bucket_name" {
      ~ id        = "learning-early-immune-wombat" -> (known after apply)
      ~ length    = 3 -> 5 # forces replacement
        # (2 unchanged attributes hidden)
```
1. Accept the change. Notice that the "bucket_name" output changes, since it's derived from the value of the random_pet.bucket_name. The bucket_arn doesn't change. Applying only part of a change tends to make your state inconsistent, which is part of why you should only use it in troubleshooting scenarios.
1. Attempt to apply the change to the bucket: `terraform apply -target=module.s3_bucket`.
  - This will fail. You cannot delete an AWS bucket unless it is empty.
```
Error: error deleting S3 Bucket (learning-overly-just-skylark): BucketNotEmpty: The bucket you tried to delete is not empty. You must delete all versions in the bucket.
	status code: 409, request id: 33FC0DD6B83C0516, host id: 62h4SQvvhgKjvrO2Rm0f7PGRbDCfIajiqrQ/WUw1PULjxN7oxRThbAeR/bNnWrhkBOdjOr7uKes=
```
1. Apply the entire change: `terraform apply`.
1. Change the content of the bucket objects.
```
-  content      = "first,second,${count.index},last"
+  content      = "first,second,${count.index},fourth"
```
1. Apply the change to a single bucket: `terraform apply -target=aws_s3_bucket_object.objects[3]`
1. Change the bucket names.
```
-  prefix    = "learning"
```
1. Attempt to apply the change to a single object: `terraform apply -target=aws_s3_bucket_object.objects[3]`.
1. Apply the rest of the change: `terraform apply`.
