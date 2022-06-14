terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
  alias  = "acm_provider"
}

# Creates s3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.domain_name
}

# Creates s3 configuration
resource "aws_s3_bucket_website_configuration" "s3_config" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Creates bucket ACL policy
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}

# Creates bucket policy
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.s3_bucket.arn}/*",
        "${aws_s3_bucket.s3_bucket.arn}"
      ]
    }
  ]
}
POLICY
}

# Adds website objects to S3
# Feature is not currently working

/*resource "aws_s3_object" "s3_objects" {
  for_each = fileset("website/", "**")
  bucket = aws_s3_bucket.s3-bucket.id
  key = each.value
  source = "website/${each.value}"
  etag = filemd5("website/${each.value}")
}*/

# Creates cloudfront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.s3_bucket.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.s3_bucket.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

  }

  enabled             = true
  default_root_object = "index.html"
  aliases             = [var.domain_name, "*.${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = 
    ssl_support_method  = "sni-only"
  }
}