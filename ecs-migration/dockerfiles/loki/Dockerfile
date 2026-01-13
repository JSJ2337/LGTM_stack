# Loki ECS Fargate Dockerfile
# Version: 3.5.1 (EC2 docker-compose 설정 기반)

FROM grafana/loki:3.5.1

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-loki"
LABEL version="3.5.1"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
# Loki 3.x는 /etc/loki/config.yaml 또는 /loki/config.yaml 경로 사용
COPY config/loki-config.yaml /etc/loki/config.yaml

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV LOKI_S3_BUCKET=jsj-lgtm-data-s3

# 포트 노출
EXPOSE 3100

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ECS Task Definition에서 설정)
# HEALTHCHECK 제거 - ALB 헬스체크 사용

# Loki 실행
CMD ["-config.file=/etc/loki/config.yaml", "-config.expand-env=true"]
