# Alloy Collector ECS Fargate Dockerfile
# Version: 1.5.1 (EC2 docker-compose 설정 기반)

FROM grafana/alloy:v1.5.1

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-alloy"
LABEL version="1.5.1"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config.d/ /etc/alloy/config.d/

# 환경변수 기본값
ENV LOKI_URL=http://loki.lgtm.local:3100/loki/api/v1/push
ENV LOKI_TENANT=ftt-cloudflare
ENV MIMIR_URL=http://mimir.lgtm.local:8080/api/v1/push
ENV MIMIR_TENANT=ftt-lgtm-rds

# 포트 노출
EXPOSE 12345 9080

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ECS Task Definition에서 설정)
# HEALTHCHECK 제거 - ALB 헬스체크 사용

# Alloy 실행 (run 서브커맨드 사용)
CMD ["run", \
    "--stability.level=experimental", \
    "--server.http.listen-addr=0.0.0.0:12345", \
    "--storage.path=/var/lib/alloy", \
    "/etc/alloy/config.d/"]
