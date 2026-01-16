# =============================================================================
# S3 Module - LGTM Data Storage
# =============================================================================

# -----------------------------------------------------------------------------
# S3 Bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "lgtm_data" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name        = var.bucket_name
    Environment = var.environment
  })
}

# -----------------------------------------------------------------------------
# Bucket Versioning - 비활성화
# LGTM 데이터는 애플리케이션에서 자동 관리되므로 버전 관리 불필요
# 버전 관리 시 스토리지 비용 증가 및 버킷 삭제 복잡성 증가
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "lgtm_data" {
  bucket = aws_s3_bucket.lgtm_data.id

  versioning_configuration {
    status = "Disabled"
  }
}

# -----------------------------------------------------------------------------
# Server-Side Encryption
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "lgtm_data" {
  bucket = aws_s3_bucket.lgtm_data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------------------------------------------------------
# Block Public Access
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "lgtm_data" {
  bucket = aws_s3_bucket.lgtm_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# Lifecycle Rules
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "lgtm_data" {
  bucket = aws_s3_bucket.lgtm_data.id

  rule {
    id     = "cleanup-incomplete-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    filter {
      prefix = ""
    }
  }
}
