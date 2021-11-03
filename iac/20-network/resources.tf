locals {
  domain_name     = "www.jrussell.ie"
  top_domain_name = "jrussell.ie"
}

resource "aws_route53_zone" "domain" {
  name = local.top_domain_name

  tags = {
    project = "about-me"
  }
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
