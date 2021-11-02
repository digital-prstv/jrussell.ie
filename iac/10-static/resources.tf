locals {
  site_name       = "www.jrussell.ie"
  expiration_days = 90
}

resource "aws_kms_key" "bucket" {
  description             = "Encrypt www.jrussell.ie static site"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.site_name}-weblogs"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id      = "log"
    enabled = true

    prefix = "log/"

    tags = {
      "rule"      = "log"
      "autoclean" = "true"
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

  lifecycle_rule {
    id      = "tmp"
    prefix  = "tmp/"
    enabled = true

    expiration {
      date = "2016-01-12"
    }
  }
}


resource "aws_s3_bucket" "www_site" {
  bucket = local.site_name

  logging {
    target_bucket = aws_s3_bucket.logs
    target_prefix = "log/${local.site_name}/"
  }

  website {
    index_document = "index.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 14
    }

  }

  depends_on = [aws_s3_bucket.logs]
}

