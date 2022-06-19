# ACM certificate
resource "aws_acm_certificate" "website_cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
}

# ACM certification validation
resource "aws_acm_certificate_validation" "website_validation" {
  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.website_records : record.fqdn]
}