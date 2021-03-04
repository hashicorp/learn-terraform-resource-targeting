# Output declarations

output "bucket_name" {
  description = "Randomly generated bucket name."
  value       = random_pet.bucket_name.id
}

output "bucket_arn" {
  description = "ARN of bucket"
  value       = module.s3_bucket.this_s3_bucket_arn
}
