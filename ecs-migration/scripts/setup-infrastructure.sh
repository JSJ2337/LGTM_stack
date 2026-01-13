#!/bin/bash
# LGTM Stack - Infrastructure Setup Script
# Usage: ./setup-infrastructure.sh

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

AWS_REGION="${AWS_REGION:-ap-northeast-2}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

ECR_REPOS=("lgtm-mimir" "lgtm-loki" "lgtm-tempo" "lgtm-pyroscope" "lgtm-grafana" "lgtm-alloy")
LOG_GROUPS=("/ecs/lgtm-mimir" "/ecs/lgtm-loki" "/ecs/lgtm-tempo" "/ecs/lgtm-pyroscope" "/ecs/lgtm-grafana" "/ecs/lgtm-alloy")

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

create_ecr_repos() {
    log_info "ECR 리포지토리 생성 중..."

    for repo in "${ECR_REPOS[@]}"; do
        if aws ecr describe-repositories --repository-names "${repo}" --region "${AWS_REGION}" &> /dev/null; then
            log_info "ECR 리포지토리 이미 존재: ${repo}"
        else
            aws ecr create-repository \
                --repository-name "${repo}" \
                --region "${AWS_REGION}" \
                --image-scanning-configuration scanOnPush=true \
                --encryption-configuration encryptionType=AES256 \
                --output text > /dev/null

            log_success "ECR 리포지토리 생성: ${repo}"
        fi
    done
}

create_log_groups() {
    log_info "CloudWatch Log Groups 생성 중..."

    for log_group in "${LOG_GROUPS[@]}"; do
        if aws logs describe-log-groups --log-group-name-prefix "${log_group}" --region "${AWS_REGION}" | grep -q "${log_group}"; then
            log_info "Log Group 이미 존재: ${log_group}"
        else
            aws logs create-log-group \
                --log-group-name "${log_group}" \
                --region "${AWS_REGION}"

            aws logs put-retention-policy \
                --log-group-name "${log_group}" \
                --retention-in-days 7 \
                --region "${AWS_REGION}"

            log_success "Log Group 생성: ${log_group}"
        fi
    done
}

create_secrets() {
    log_info "Secrets Manager 시크릿 확인 중..."

    local secret_name="lgtm/grafana-admin-password"

    if aws secretsmanager describe-secret --secret-id "${secret_name}" --region "${AWS_REGION}" &> /dev/null; then
        log_info "시크릿 이미 존재: ${secret_name}"
    else
        log_info "Grafana 관리자 비밀번호를 입력하세요:"
        read -s GRAFANA_PASSWORD

        aws secretsmanager create-secret \
            --name "${secret_name}" \
            --description "Grafana admin password for LGTM Stack" \
            --secret-string "${GRAFANA_PASSWORD}" \
            --region "${AWS_REGION}" \
            --output text > /dev/null

        log_success "시크릿 생성: ${secret_name}"
    fi
}

show_terraform_instructions() {
    echo ""
    log_info "=========================================="
    log_info "Terraform 실행 안내"
    log_info "=========================================="
    echo ""
    echo "1. terraform.tfvars 파일 생성:"
    echo "   cd ${PROJECT_ROOT}/terraform/environments/prod"
    echo "   cp terraform.tfvars.example terraform.tfvars"
    echo "   # terraform.tfvars 파일을 환경에 맞게 수정"
    echo ""
    echo "2. Terraform 실행:"
    echo "   terraform init"
    echo "   terraform plan"
    echo "   terraform apply"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    log_info "=========================================="
    log_info "LGTM Stack Infrastructure Setup"
    log_info "AWS Region: ${AWS_REGION}"
    log_info "=========================================="

    create_ecr_repos
    create_log_groups
    create_secrets

    show_terraform_instructions

    log_success "인프라 사전 설정 완료!"
}

main "$@"
