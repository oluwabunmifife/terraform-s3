terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region

}

# resource "aws_kms_key" "store-key" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

resource "aws_s3_bucket" "store-ket" {
  bucket = var.bucket_name

  tags = {
    Name        = "dev-bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "buk-own" {
  bucket = aws_s3_bucket.store-ket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Disable bucket default security
resource "aws_s3_bucket_public_access_block" "pub-block" {
  bucket = aws_s3_bucket.store-ket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "buk-acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.buk-own,
    aws_s3_bucket_public_access_block.pub-block,
  ]

  bucket = aws_s3_bucket.store-ket.id
  acl    = "public-read"
}

# Enable read access
resource "aws_s3_bucket_policy" "allow-public-access" {
  bucket = aws_s3_bucket.store-ket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.store-ket.arn}/*"
        ]
      }
    ]
  })
}

# Enable versioning
resource "aws_s3_bucket_versioning" "store-ket-versioning" {
  bucket = aws_s3_bucket.store-ket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt-ket" {
  bucket = aws_s3_bucket.store-ket.id

  rule {
    apply_server_side_encryption_by_default {
      # kms_master_key_id = aws_kms_key.store-key.arn
      sse_algorithm     = "AES256"
    }
  }
}

# CORS configuration
resource "aws_s3_bucket_cors_configuration" "cor-config" {
  bucket = aws_s3_bucket.store-ket.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}

# Upload index.html file to bucket
resource "aws_s3_object" "upload" {
  key                    = "index.html"
  bucket                 = aws_s3_bucket.store-ket.id
  source                 = "buk-list/index.html"
  acl                    = "public-read"
  server_side_encryption = "AES256"
  content_type           = "text/html"
}