output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.store-ket.bucket
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.store-ket.arn
}

output "bucket_url" {
  description = "The URL of the S3 bucket"
  value       = format("https://%s.s3.amazonaws.com/%s", aws_s3_bucket.store-ket.bucket, aws_s3_object.upload.key)
}