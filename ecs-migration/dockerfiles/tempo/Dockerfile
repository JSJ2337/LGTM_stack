# Tempo ECS Fargate Dockerfile
# 빌드: docker build --build-arg VERSION=2.9.0 -t lgtm-tempo .

ARG VERSION=2.9.0
FROM grafana/tempo:${VERSION}

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-tempo"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config/tempo-config.yaml /etc/tempo/tempo.yaml

# 환경변수는 런타임에 주입 (하드코딩 금지)
# AWS_REGION, TEMPO_S3_BUCKET 등은 ECS Task Definition에서 설정

# 포트 노출
EXPOSE 3200 4317 4318

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ALB 헬스체크 사용)

# Tempo 실행
CMD ["-config.file=/etc/tempo/tempo.yaml", "-config.expand-env=true"]
