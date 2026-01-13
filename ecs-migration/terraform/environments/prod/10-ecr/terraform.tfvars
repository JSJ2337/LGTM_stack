# =============================================================================
# 10-ECR Root Module - Production Configuration
# =============================================================================
# 사용법: terraform apply -var-file="../common.tfvars" -var-file="terraform.tfvars"
# =============================================================================

# -----------------------------------------------------------------------------
# ECR 설정
# -----------------------------------------------------------------------------

repositories = [
  "lgtm-mimir",
  "lgtm-loki",
  "lgtm-tempo",
  "lgtm-pyroscope",
  "lgtm-grafana",
  "lgtm-alloy"
]

image_tag_mutability           = "MUTABLE"
scan_on_push                   = true
lifecycle_policy_keep_count    = 30
lifecycle_policy_untagged_days = 7
