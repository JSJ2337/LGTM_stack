# Alloy Collector ECS Fargate Dockerfile
# 빌드: docker build --build-arg VERSION=1.9.2 -t lgtm-alloy .

ARG VERSION=1.9.2
FROM grafana/alloy:v${VERSION}

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-alloy"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config.d/ /etc/alloy/config.d/

# 환경변수는 런타임에 주입 (하드코딩 금지)
# LOKI_URL, MIMIR_URL, LOKI_TENANT, MIMIR_TENANT 등은 ECS Task Definition에서 설정

# 포트 노출
EXPOSE 12345 9080

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ALB 헬스체크 사용)

# Alloy 실행 (run 서브커맨드 사용)
CMD ["run", \
    "--stability.level=experimental", \
    "--server.http.listen-addr=0.0.0.0:12345", \
    "--storage.path=/var/lib/alloy", \
    "/etc/alloy/config.d/"]
