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

  tags = {
    project = "about-me"
  }
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

resource "aws_route53_record" "google-mx" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = ""
  type    = "MX"
  ttl     = "3600"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "gmx1"
  records = [
    "1 aspmx.l.google.com",
    "5 alt1.aspmx.l.google.com",
    "5 alt2.aspmx.l.google.com",
    "10 aspmx2.googlemail.com",
    "10 aspmx3.googlemail.com"
  ]
}

resource "aws_route53_record" "google-txt" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = ""
  type    = "TXT"
  ttl     = "14400"

  records = ["v=spf1 include:_spf.google.com ~all"]
}
