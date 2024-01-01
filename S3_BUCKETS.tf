# Generate a random name for the S3 bucket.

resource "random_id" "random" {
  byte_length = 4
}

#Create a private S3 bucket.

resource "aws_s3_bucket" "private_bucket" {
  bucket        = "my-${var.aws_profile}-bucket-${random_id.random.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.private_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
