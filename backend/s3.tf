# Root S3 bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.domain_name
}

# Root S3 bucket configuration
resource "aws_s3_bucket_website_configuration" "s3_config" {
  bucket = aws_s3_bucket.s3_bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Root S3 bucket ACL
resource "aws_s3_bucket_acl" "s3_bucket_acl" {
  bucket = aws_s3_bucket.s3_bucket.id
  acl    = "public-read"
}

# Root S3 bucket policy
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

# Root S3 bucket objects
# # Feature is not currently working
/*resource "aws_s3_object" "s3_objects" {
  for_each = fileset("website/", "**")
  bucket = aws_s3_bucket.s3_bucket.id
  key = each.value
  source = "website/${each.value}"
  etag = filemd5("website/${each.value}")
}*/

# Redirect S3 bucket
resource "aws_s3_bucket" "s3_redirect_bucket" {
  bucket = "www.${var.domain_name}"
}

# Redirect S3 bucket config
resource "aws_s3_bucket_website_configuration" "s3_redirect_config" {
  bucket = aws_s3_bucket.s3_redirect_bucket.bucket
  redirect_all_requests_to {
    host_name = aws_s3_bucket.s3_bucket.id
  }
}