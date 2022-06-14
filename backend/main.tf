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
}

# # Creates S3 bucket
resource "aws_s3_bucket" "s3-bucket" {
  bucket = "mileshoover.com"
}

# Configures S3 options
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.s3-bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Sets ACL policy
resource "aws_s3_bucket_acl" "s3-bucket-acl" {
  bucket = aws_s3_bucket.s3-bucket.id
  acl    = "public-read"
}

# Sets bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3-bucket.id
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
        "${aws_s3_bucket.s3-bucket.arn}/*",
        "${aws_s3_bucket.s3-bucket.arn}"
      ]
    }
  ]
}
POLICY
}

# Adds website objects to S3
# Feature is not currently working

/*resource "aws_s3_object" "objects" {
  for_each = fileset("website/", "**")
  bucket = aws_s3_bucket.s3-bucket.id
  key = each.value
  source = "website/${each.value}"
  etag = filemd5("website/${each.value}")
}*/




