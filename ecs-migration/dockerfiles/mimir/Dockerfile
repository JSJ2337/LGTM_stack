# Mimir ECS Fargate Dockerfile
# Version: 2.16.0 (EC2 docker-compose 설정 기반)

FROM grafana/mimir:2.16.0

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-mimir"
LABEL version="2.16.0"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
# Mimir는 /etc/mimir/config.yaml 경로 사용
COPY config/mimir-config.yaml /etc/mimir/config.yaml

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV MIMIR_S3_BUCKET=jsj-lgtm-data-s3

# 포트 노출
EXPOSE 8080 9095 7946

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ECS Task Definition에서 설정)
# HEALTHCHECK 제거 - ALB 헬스체크 사용

# Mimir 실행
CMD ["-config.file=/etc/mimir/config.yaml", "-config.expand-env=true", "-target=all"]
