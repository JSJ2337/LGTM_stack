# Pyroscope ECS Fargate Dockerfile
# Version: 1.11.1 (EC2 docker-compose 설정 기반)

FROM grafana/pyroscope:1.11.1

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-pyroscope"
LABEL version="1.11.1"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config/pyroscope-config.yaml /etc/pyroscope/config.yaml

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV TZ=Asia/Seoul

# 포트 노출
EXPOSE 4040 4041

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ECS Task Definition에서 설정)
# HEALTHCHECK 제거 - ALB 헬스체크 사용

# Pyroscope 실행
CMD ["/usr/bin/pyroscope", \
    "--config.file=/etc/pyroscope/config.yaml", \
    "--target=all"]
