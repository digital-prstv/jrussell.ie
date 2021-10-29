resource "aws_kms_key" "bucket" {
  description             = "Key to encrypt terraform remote state store"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "racing-iac-state"
  acl    = "private"

  tags = {
    Name    = "Racing Lambdas Terraform Remote State"
    Project = "racing-lambdas"
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
}
