locals {
  site_name       = "www.jrussell.ie"
  expiration_days = 90
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.site_name}-weblogs"
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.logs.id

  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id      = "log"
    status  = "enabled"

    filter {
      and {

        prefix = "log/"

        tags = {
          "rule"      = "log"
          "autoclean" = "true"
        } 
      }
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }

    expiration {
      days = local.expiration_days
    }
  }

  rule {
    id      = "tmp"
    filter {
      prefix  = "tmp/"
    }
    status  = "Enabled"

    expiration {
      date = "2016-01-12"
    }
  }
}


resource "aws_s3_bucket" "www_site" {
  bucket = local.site_name

}

resource "aws_s3_bucket_website_configuration" "www_site" {
  bucket = aws_s3_bucket.www_site.id
  
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_cors_configuration"  "www_site" {
  bucket = aws_s3_bucket.www_site.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["https://www.jrussell.ie"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

}

resource "aws_s3_bucket_logging" "www_site" {
  bucket = aws_s3_bucket.www_site.id

    target_bucket = aws_s3_bucket.logs.id
    target_prefix = "log/${local.site_name}/"
  }

  # server_side_encryption_configuration {
  #   rule {
  #     apply_server_side_encryption_by_default {
  #       sse_algorithm = "AES256"
  #     }
  #   }
  # }

resource "aws_s3_bucket_versioning" "www_site" {
  bucket = aws_s3_bucket.www_site.id

  versioning_configuration {
    status = "Enabled"
}

  }

  resource "aws_s3_bucket_lifecycle_configuration" "www_site" { 
    bucket = aws_s3_bucket.www_site.id
  depends_on = [aws_s3_bucket.logs]

  rule {
    id = "log"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 14
    }

  }

}

