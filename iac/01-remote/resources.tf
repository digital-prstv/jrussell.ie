resource "aws_kms_key" "bucket" {
  description             = "Key to encrypt terraform remote state store"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    project  = "about-me"
    resource = "iac-store"
  }

}

resource "aws_kms_alias" "remote-bucket" {
  name          = "alias/iac/jrussell-ie"
  target_key_id = aws_kms_key.bucket.key_id
}

resource "aws_s3_bucket" "tf_remote_state" {
  bucket = "jrussell-iac-state"

  tags = {
    Name    = "www.jrussell.ie"
    Project = "about-me"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_remote_state" {
  bucket = aws_s3_bucket.tf_remote_state.id
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.bucket.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

resource "aws_s3_bucket_versioning" "tf_remote_state" {
  bucket = aws_s3_bucket.tf_remote_state.id

  versioning_configuration {
    status = enabled
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_remote_state" {
  depends_on = [ aws_s3_bucket_versioning.tf_remote_state ]
  bucket = aws_s3_bucket.tf_remote_state.id

  rule {
    id = "config"
    noncurrent_version_expiration {
      noncurrent_days = 14
    }

    status = "Enabled"
  }
}
