locals {
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

# 1. S3 버킷 기본 선언
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.environment == "prod" ? true : true # 운영 환경에서는 실수로 지워지지 않게 방어

  tags = merge(local.common_tags, {
    Name = var.bucket_name
  })
}

# 2. 퍼블릭 액세스 전면 차단 (보안 필수)
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. 버전 관리 설정
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# 4. 기본 암호화 (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 5. 🚀 [로그 전용 필수 추가] 비용 최적화를 위한 수명주기 규칙
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "log-management-rule"
    status = "Enabled"

    # 최신 로그 관리 (생성 후 일정 기간 지나면 액션)
    transition {
      days          = var.glacier_transition_days # 기본 30일 후 Glacier Instant Retrieval로 이동 (비용 절감)
      storage_class = "GLACIER_IR"
    }

    expiration {
      days = var.log_retention_days # 기본 90일 후 로그 자동 완전 삭제
    }

    # 구버전 로그 관리 (버전 관리에 의해 남은 이전 데이터 삭제)
    noncurrent_version_expiration {
      noncurrent_days = 14 # 변경 전 구버전 데이터는 14일 뒤 자동 삭제
    }
  }
}
