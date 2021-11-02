locals {
  domain_name     = "www.jrussell.ie"
  top_domain_name = "jrussell.ie"
}

resource "aws_acm_certificate" "domain_certificate" {
  domain_name       = local.domain_name
  validation_method = "DNS"

  tags = {
    Name    = "${local.domain_name}-Certificate"
    project = "about-me"
  }
}

resource "aws_route53_zone" "domain" {
  name = local.top_domain_name
}

resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.domain_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = aws_route53_zone.domain.zone_id
}

resource "aws_acm_certificate_validation" "domain_certificate_validation" {
  certificate_arn         = aws_acm_certificate.domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}

