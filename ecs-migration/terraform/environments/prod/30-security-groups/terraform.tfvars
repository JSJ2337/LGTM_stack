# =============================================================================
# 30-Security Groups Root Module - Production Configuration
# =============================================================================
# 사용법: terraform apply -var-file="../common.tfvars"
# 모든 설정은 common.tfvars에서 관리됩니다.
# =============================================================================

# Security Groups 설정은 common.tfvars에서 관리:
# - state_bucket
# - alb_ingress_rules
# - ecs_service_ports
