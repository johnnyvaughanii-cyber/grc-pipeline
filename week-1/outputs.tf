output "bucket_name" {
  description = "Primary bucket name."
  value       = aws_s3_bucket.primary.id
}

output "bucket_arn" {
  description = "Primary bucket ARN."
  value       = aws_s3_bucket.primary.arn
}

output "log_bucket_name" {
  description = "Log bucket name."
  value       = aws_s3_bucket.log.id
}

# TODO (SC-28 attestation): once you add the encryption configuration, add an
# output that surfaces the algorithm in effect (for example "AES256"). This is
# your machine-readable proof of encryption at rest.
output "sc28_encryption_algorithm" {
  description = "SC-28 attestation: server-side encryption algorithm in effect on the primary bucket."
  value       = one(one(aws_s3_bucket_server_side_encryption_configuration.primary.rule).apply_server_side_encryption_by_default).sse_algorithm
}