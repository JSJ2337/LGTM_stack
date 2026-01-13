#!/bin/bash
# LGTM Stack - Build All Docker Images
# Usage: ./build-all.sh [tag]

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCKERFILES_DIR="${PROJECT_ROOT}/dockerfiles"

AWS_REGION="${AWS_REGION:-ap-northeast-2}"
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text 2>/dev/null || echo '')}"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

IMAGE_TAG="${1:-latest}"
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

check_prerequisites() {
    log_info "필수 도구 확인 중..."

    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되어 있지 않습니다."
        exit 1
    fi

    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI가 설치되어 있지 않습니다."
        exit 1
    fi

    if [[ -z "${AWS_ACCOUNT_ID}" ]]; then
        log_error "AWS Account ID를 가져올 수 없습니다. AWS 자격 증명을 확인하세요."
        exit 1
    fi

    log_info "AWS Account ID: ${AWS_ACCOUNT_ID}"
    log_info "ECR Registry: ${ECR_REGISTRY}"
}

ecr_login() {
    log_info "ECR 로그인 중..."
    aws ecr get-login-password --region "${AWS_REGION}" | \
        docker login --username AWS --password-stdin "${ECR_REGISTRY}"
}

build_image() {
    local component="$1"
    local dockerfile_dir="${DOCKERFILES_DIR}/${component}"
    local image_name="lgtm-${component}"
    local full_image="${ECR_REGISTRY}/${image_name}"

    if [[ ! -d "${dockerfile_dir}" ]]; then
        log_error "Dockerfile 디렉토리를 찾을 수 없습니다: ${dockerfile_dir}"
        return 1
    fi

    log_info "Building ${component}..."

    docker build \
        --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
        --build-arg GIT_COMMIT="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" \
        -t "${full_image}:${IMAGE_TAG}" \
        -t "${full_image}:$(date +%Y%m%d-%H%M%S)" \
        "${dockerfile_dir}"

    log_success "${component} 빌드 완료"
}

push_image() {
    local component="$1"
    local image_name="lgtm-${component}"
    local full_image="${ECR_REGISTRY}/${image_name}"

    log_info "Pushing ${component} to ECR..."

    docker push "${full_image}:${IMAGE_TAG}"

    log_success "${component} 푸시 완료"
}

# =============================================================================
# Main
# =============================================================================

main() {
    log_info "=========================================="
    log_info "LGTM Stack Docker Build Script"
    log_info "Image Tag: ${IMAGE_TAG}"
    log_info "=========================================="

    check_prerequisites
    ecr_login

    local failed_builds=()

    for component in "${COMPONENTS[@]}"; do
        if build_image "${component}"; then
            push_image "${component}" || failed_builds+=("${component}")
        else
            failed_builds+=("${component}")
        fi
    done

    echo ""
    log_info "=========================================="
    if [[ ${#failed_builds[@]} -eq 0 ]]; then
        log_success "모든 이미지 빌드 및 푸시 완료!"
    else
        log_error "실패한 컴포넌트: ${failed_builds[*]}"
        exit 1
    fi
}

main "$@"
