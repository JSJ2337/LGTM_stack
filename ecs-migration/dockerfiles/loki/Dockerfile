# Loki ECS Fargate Dockerfile
# 빌드: docker build --build-arg VERSION=3.5.1 -t lgtm-loki .

ARG VERSION=3.5.1
FROM grafana/loki:${VERSION}

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-loki"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config/loki-config.yaml /etc/loki/config.yaml

# 환경변수는 런타임에 주입 (하드코딩 금지)
# AWS_REGION, LOKI_S3_BUCKET 등은 ECS Task Definition에서 설정

# 포트 노출
EXPOSE 3100

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ALB 헬스체크 사용)

# Loki 실행
CMD ["-config.file=/etc/loki/config.yaml", "-config.expand-env=true"]
