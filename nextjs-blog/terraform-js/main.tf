# Defines AWS as the cloud provider and sets the AWS Region
provider "aws" {
  region =  "af-south-1"
}

/* S3 BUCKET CONFIGURATIONS */

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

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
      }
    ]
  })
}

/* CLOUDFRONT CONFIGURATIONS */

# Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI for Next.JS portfolio site"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "nextjs_distribution" {

  origin {
    domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
    origin_id = "S3-nextjs-portfolio-bucket"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled = true # Activate CloudFront Distribution to serve content
  is_ipv6_enabled = true # Enables IPv6 support
  comment = "Next.js portfolio site"
  default_root_object = "index.html" # File to be served

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"] # HTTP methods allowed for caching behaviour
    cached_methods = ["GET", "HEAD"] # Methods to be cached
    target_origin_id = "S3-nextjs-portfolio-bucket" # Links cache behaviour to the origin

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

    }

    viewer_protocol_policy = "redirect-to-https" # Ensures secure connection between CDN & Client
    min_ttl = 0 # Min. amount of time an object is cached
    default_ttl = 3600 # Default amount of time an object is cached
    max_ttl = 86400 # Max. amount of time an object is cached
  }

  restrictions {
    geo_restriction {
      restriction_type = "none" # All geographic locations are allowed
    }
  }

  viewer_certificate {
    # Configure SSL and TSL settings
    cloudfront_default_certificate = true
  }

}