locals {
  site_name        = "www.jrussell.ie"
  route_53_domain  = "jrussell.ie"
  rewriter         = "website-rewriter"
  security_headers = "response-security-headers"
  project          = "about-me"
  rewriter_version = "1"
  security_version = "32"
}
data "aws_s3_bucket" "static_site" {
  provider = aws.eu
  bucket   = local.site_name
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  provider = aws.us
  comment  = "Acecss Identity for ${local.site_name}"
}

data "aws_lambda_function" "website_rewriter" {
  provider      = aws.us
  function_name = local.rewriter
}

data "aws_lambda_function" "response_security_headers" {
  provider      = aws.us
  function_name = local.security_headers
}

resource "aws_cloudfront_distribution" "website_cdn" {
  provider     = aws.us
  enabled      = true
  price_class  = "PriceClass_100"
  http_version = "http1.1"
  aliases      = [local.site_name]

  origin {
    origin_id   = "origin-bucket-${data.aws_s3_bucket.static_site.id}"
    domain_name = "${data.aws_s3_bucket.static_site.id}.s3.${module.shared.region}.amazonaws.com"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-bucket-${data.aws_s3_bucket.static_site.id}"
    min_ttl                = "0"
    default_ttl            = "300"  //3600
    max_ttl                = "1200" //86400
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = "${data.aws_lambda_function.website_rewriter.arn}:${local.rewriter_version}"
    }

    lambda_function_association {
      event_type = "origin-response"
      lambda_arn = "${data.aws_lambda_function.response_security_headers.arn}:${local.security_version}"
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.amazon_issued.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }


  tags = {
    Name    = "${local.site_name}-Cloudfront-Distribution"
    Project = local.project
  }


}

# Find a certificate issued by (not imported into) ACM
data "aws_acm_certificate" "amazon_issued" {
  provider    = aws.eu
  domain      = local.site_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

data "aws_route53_zone" "site" {
  provider = aws.eu
  name     = local.route_53_domain
}


resource "aws_route53_record" "www_site" {
  provider = aws.eu
  zone_id  = data.aws_route53_zone.site.zone_id
  name     = local.site_name
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
