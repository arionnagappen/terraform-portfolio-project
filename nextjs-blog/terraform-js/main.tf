# Defines AWS as the cloud provider and sets the AWS Region
provider "aws" {
  region =  "af-south-1"
}

# S3 Bucket to store static files for the website
resource "aws_s3_bucket" "nextjs_bucket" {
  bucket = "nextjs-portfolio-bucket-an"
}

# Ownership control of the S3 bucket
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  rule {
    # Only Owner of the bucket has complete control over all objects in the bucket
    object_ownership = "BucketOwnerPreferred" 
  }
}

# Enables Public Access to the bucket
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

# Sets the bucket ACL to allow everyone to read its objects
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
  depends_on = [ 
    aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
   ]

  bucket = aws_s3_bucket.nextjs_bucket.id
  acl = "public-read"
}

# Bucket Policy
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  policy = jsonencode(({
    version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.nextjs_bucket.id.arn}/*"
      }
    ]
  }))
}