# =============================================================================
# 10-ECR Root Module - Production Configuration
# =============================================================================
# 사용법: terraform apply -var-file="../common.tfvars"
# 모든 설정은 common.tfvars에서 관리됩니다.
# =============================================================================

# ECR 설정은 common.tfvars에서 관리:
# - ecr_repositories
# - ecr_image_tag_mutability
# - ecr_scan_on_push
# - ecr_lifecycle_policy_keep_count
# - ecr_lifecycle_policy_untagged_days
