# Route53 hosted zone data
data "aws_route53_zone" "website_zone" {
  name = var.domain_name
}

# Route53 records
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

# Route53 record for root domain
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

# Route53 record for subdomain 'www.'
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