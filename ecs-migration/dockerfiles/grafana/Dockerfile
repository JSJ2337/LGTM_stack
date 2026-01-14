# Grafana ECS Fargate Dockerfile
# 빌드: docker build --build-arg VERSION=12.1.0 -t lgtm-grafana .

ARG VERSION=12.1.0
FROM grafana/grafana:${VERSION}

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-grafana"
LABEL environment="production"

# 프로비저닝 설정 파일 복사
COPY config/provisioning/ /etc/grafana/provisioning/

# 환경변수는 런타임에 주입 (하드코딩 금지)
# GF_SECURITY_ADMIN_PASSWORD, GF_SERVER_ROOT_URL 등은 ECS Task Definition에서 설정

# 포트 노출
EXPOSE 3000

# 헬스체크 (Grafana는 Alpine 기반, wget 사용 가능)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/api/health || exit 1

# Grafana 실행
CMD ["/run.sh"]
