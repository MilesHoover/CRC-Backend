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

# Creates S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.domain_name
}

# Creates S3 configuration
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
  bucket = aws_s3_bucket.s3_bucket.id
  key = each.value
  source = "website/${each.value}"
  etag = filemd5("website/${each.value}")
}*/

# Creates redirect bucket
resource "aws_s3_bucket" "s3_redirect_bucket" {
  bucket = "www.${var.domain_name}"
}

# Creates S3 redirect configuration
resource "aws_s3_bucket_website_configuration" "s3_redirect_config" {
  bucket = aws_s3_bucket.s3_redirect_bucket.bucket
  redirect_all_requests_to {
    host_name = aws_s3_bucket.s3_bucket.id
  }
}

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
    acm_certificate_arn = aws_acm_certificate_validation.website_validation.certificate_arn
    ssl_support_method  = "sni-only"
  }
}

# Creates ACM certificate
resource "aws_acm_certificate" "website_cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
}

# Validates ACM certification
resource "aws_acm_certificate_validation" "website_validation" {
  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.website_records : record.fqdn]
}

# Gives data about Route53 hosted zone
data "aws_route53_zone" "website_zone" {
  name = var.domain_name
}

# Creates Route53 records
resource "aws_route53_record" "website_records" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.website_zone.zone_id
}

# Creates Route53 record for root website
resource "aws_route53_record" "root_record" {
  zone_id = data.aws_route53_zone.website_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

# Creates Route53 record for 'www' website
resource "aws_route53_record" "www_record" {
  zone_id = data.aws_route53_zone.website_zone.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
  name                   = aws_s3_bucket.s3_redirect_bucket.website_domain
  zone_id                = aws_s3_bucket.s3_redirect_bucket.hosted_zone_id
  evaluate_target_health = true
  }
}

resource "aws_dynamodb_table" "count_db"{
  name = "count_db"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "PK"

  attribute {
    name = "PK"
    type = "N"
  }
}