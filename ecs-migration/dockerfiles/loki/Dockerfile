# Loki ECS Fargate Dockerfile
# Version: 3.5.1 (EC2 docker-compose 설정 기반)

FROM grafana/loki:3.5.1

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-loki"
LABEL version="3.5.1"
LABEL environment="production"

# 설정 파일 복사
USER root
COPY config/loki-config.yaml /etc/loki/loki-config.yaml

# 데이터 디렉토리 생성
RUN mkdir -p /loki/wal /loki/index /loki/index_cache /loki/compactor && \
    chown -R 10001:10001 /loki

# 비root 유저로 전환
USER 10001

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV LOKI_S3_BUCKET=sys-lgtm-s3

# 포트 노출
EXPOSE 3100

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3100/ready || exit 1

# Loki 실행
CMD ["/usr/bin/loki", \
    "-config.file=/etc/loki/loki-config.yaml", \
    "-config.expand-env=true", \
    "-log.level=warn"]
