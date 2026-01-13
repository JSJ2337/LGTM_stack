# =============================================================================
# 50-ALB Root Module - Production Configuration
# =============================================================================
# 사용법: terraform apply -var-file="../common.tfvars"
# 모든 설정은 common.tfvars에서 관리됩니다.
# =============================================================================

# ALB 설정은 common.tfvars에서 관리:
# - state_bucket
# - alb_internal
# - alb_enable_deletion_protection
# - alb_certificate_arn
# - alb_health_check_config
