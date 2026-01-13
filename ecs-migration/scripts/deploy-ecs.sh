#!/bin/bash
# LGTM Stack - Deploy to ECS
# Usage: ./deploy-ecs.sh [component|all]

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

AWS_REGION="${AWS_REGION:-ap-northeast-2}"
ECS_CLUSTER="${ECS_CLUSTER:-lgtm-prod-cluster}"

COMPONENT="${1:-all}"
COMPONENTS=("mimir" "loki" "tempo" "pyroscope" "grafana" "alloy")

# =============================================================================
# Functions
# =============================================================================

log_info() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_success() {
    echo "[SUCCESS] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

deploy_service() {
    local service="$1"

    log_info "Deploying ${service}..."

    aws ecs update-service \
        --cluster "${ECS_CLUSTER}" \
        --service "${service}" \
        --force-new-deployment \
        --region "${AWS_REGION}" \
        --output text > /dev/null

    log_info "Waiting for ${service} to stabilize..."

    aws ecs wait services-stable \
        --cluster "${ECS_CLUSTER}" \
        --services "${service}" \
        --region "${AWS_REGION}"

    log_success "${service} 배포 완료"
}

check_service_status() {
    local service="$1"

    local running_count=$(aws ecs describe-services \
        --cluster "${ECS_CLUSTER}" \
        --services "${service}" \
        --query 'services[0].runningCount' \
        --output text \
        --region "${AWS_REGION}")

    local desired_count=$(aws ecs describe-services \
        --cluster "${ECS_CLUSTER}" \
        --services "${service}" \
        --query 'services[0].desiredCount' \
        --output text \
        --region "${AWS_REGION}")

    echo "${service}: Running ${running_count}/${desired_count}"

    if [[ "${running_count}" -lt "${desired_count}" ]]; then
        return 1
    fi
    return 0
}

# =============================================================================
# Main
# =============================================================================

main() {
    log_info "=========================================="
    log_info "LGTM Stack ECS Deployment Script"
    log_info "Cluster: ${ECS_CLUSTER}"
    log_info "Component: ${COMPONENT}"
    log_info "=========================================="

    local services_to_deploy=()

    if [[ "${COMPONENT}" == "all" ]]; then
        services_to_deploy=("${COMPONENTS[@]}")
    else
        if [[ " ${COMPONENTS[*]} " =~ " ${COMPONENT} " ]]; then
            services_to_deploy=("${COMPONENT}")
        else
            log_error "Unknown component: ${COMPONENT}"
            log_info "Available components: ${COMPONENTS[*]}"
            exit 1
        fi
    fi

    local failed_deploys=()

    for service in "${services_to_deploy[@]}"; do
        if ! deploy_service "${service}"; then
            failed_deploys+=("${service}")
        fi
    done

    echo ""
    log_info "=========================================="
    log_info "Service Status:"
    log_info "=========================================="

    for service in "${services_to_deploy[@]}"; do
        check_service_status "${service}" || true
    done

    echo ""
    if [[ ${#failed_deploys[@]} -eq 0 ]]; then
        log_success "모든 서비스 배포 완료!"
    else
        log_error "실패한 서비스: ${failed_deploys[*]}"
        exit 1
    fi
}

main "$@"
