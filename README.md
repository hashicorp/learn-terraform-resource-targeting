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
1. Observe that changing the name will replace several resources (the bucket name, bucket, bucket objects, and bucket notification), and update one in place (the SNS topic policy).
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
1. Plan the change again, but only target the bucket name: `terraform plan -target=random_pet.bucket_name`.
```
  # random_pet.bucket_name must be replaced
-/+ resource "random_pet" "bucket_name" {
      ~ id        = "learning-early-immune-wombat" -> (known after apply)
      ~ length    = 3 -> 5 # forces replacement
        # (2 unchanged attributes hidden)
```
1. Apply and accept the change: `terraform apply -target=random_pet.bucket_name`
  - Notice that the "bucket_name" output changes, since it's derived from the value of the random_pet.bucket_name. The bucket_arn doesn't change. Applying only part of a change tends to make your state inconsistent, which is part of why you should only use it in troubleshooting scenarios.
1. Attempt to apply the change to the bucket. This will fail: `terraform apply -target=module.s3_bucket`.
  - Since you're targeting the module, both of the resources inside the module are included.
  `Plan: 2 to add, 0 to change, 2 to destroy.`
  - You cannot delete an AWS bucket unless it is empty, so Terraform
```
Error: error deleting S3 Bucket (learning-overly-just-skylark): BucketNotEmpty: The bucket you tried to delete is not empty. You must delete all versions in the bucket.
	status code: 409, request id: 33FC0DD6B83C0516, host id: 62h4SQvvhgKjvrO2Rm0f7PGRbDCfIajiqrQ/WUw1PULjxN7oxRThbAeR/bNnWrhkBOdjOr7uKes=
```
1. Apply the entire change: `terraform apply`.
  - Notice that Terraform knows to avoid the above error...it deletes the bucket objects first, then the bucket.
1. Change the content of the bucket objects.
```
-  content      = "first,second,${count.index},last"
+  content      = "first,second,${count.index},fourth"
```
1. Apply the change to two of the bucket objects: `terraform apply -target=aws_s3_bucket_object.objects[2] -target=aws_s3_bucket_object.objects[3]`
  - Observe that only the targeted objects are updated, as expected.
  - You can target an individual resource in a collection. However, dependencies are calculated at the resource level.
1. Change the bucket object names.
```
-  prefix    = "learning"
```
1. Attempt to apply the change to a single object: `terraform apply -target=aws_s3_bucket_object.objects[2]`.
  - Notice that all of the `random_pet.object_names` resources will be replaced as well.
```
Plan: 5 to add, 0 to change, 5 to destroy.
```
1. Apply the rest of the change: `terraform apply`.
1. You can also use target when destroying infrastructure: `terraform destroy -target=aws_s3_bucket_notification.notif -target=aws_s3_bucket_object.objects`
1. Accept the change.
1. Destroy the rest of the infrastructure: `terraform destroy`.
