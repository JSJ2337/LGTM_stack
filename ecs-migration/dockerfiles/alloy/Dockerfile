# Alloy Collector ECS Fargate Dockerfile
# Version: 1.5.1 (EC2 docker-compose 설정 기반)

FROM grafana/alloy:v1.5.1

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-alloy"
LABEL version="1.5.1"
LABEL environment="production"

# 설정 디렉토리 생성
USER root
RUN mkdir -p /etc/alloy/config.d /var/lib/alloy /data/alloy-remote-config

# 설정 파일 복사
COPY config.d/ /etc/alloy/config.d/

# 권한 설정
RUN chown -R 10001:10001 /etc/alloy /var/lib/alloy /data

# 비root 유저로 전환
USER 10001

# 환경변수 기본값
ENV LOKI_URL=http://loki.lgtm.local:3100/loki/api/v1/push
ENV LOKI_TENANT=ftt-cloudflare
ENV MIMIR_URL=http://mimir.lgtm.local:8080/api/v1/push
ENV MIMIR_TENANT=ftt-lgtm-rds

# 포트 노출
EXPOSE 12345 9080

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:12345/-/healthy || exit 1

# Alloy 실행
CMD ["/bin/alloy", "run", \
    "--stability.level=experimental", \
    "--server.http.listen-addr=0.0.0.0:12345", \
    "--storage.path=/var/lib/alloy", \
    "/etc/alloy/config.d/"]
