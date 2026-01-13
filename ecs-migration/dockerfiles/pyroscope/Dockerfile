# Pyroscope ECS Fargate Dockerfile
# Version: latest (EC2 docker-compose 설정 기반)

FROM grafana/pyroscope:1.11.1

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-pyroscope"
LABEL version="1.11.1"
LABEL environment="production"

# Tini init 시스템 설치 (Graceful Shutdown)
USER root
RUN apk add --no-cache tini curl

# 설정 파일 복사
COPY config/pyroscope-config.yaml /etc/pyroscope/config.yaml

# 데이터 디렉토리 생성
RUN mkdir -p /data && \
    chown -R pyroscope:pyroscope /data

# 비root 유저로 전환
USER pyroscope

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV TZ=Asia/Seoul

# 포트 노출
EXPOSE 4040 4041

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:4040/ready || exit 1

# Tini를 통한 Graceful Shutdown
ENTRYPOINT ["/sbin/tini", "--"]

# Pyroscope 실행
CMD ["/usr/bin/pyroscope", \
    "--config.file=/etc/pyroscope/config.yaml", \
    "--target=all"]
