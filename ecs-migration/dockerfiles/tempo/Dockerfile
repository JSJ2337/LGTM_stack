# Tempo ECS Fargate Dockerfile
# Version: 2.7.2 (EC2 docker-compose 설정 기반)

FROM grafana/tempo:2.7.2

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-tempo"
LABEL version="2.7.2"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config/tempo-config.yaml /etc/tempo/tempo.yaml

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2

# 포트 노출
EXPOSE 3200 4317 4318

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ECS Task Definition에서 설정)
# HEALTHCHECK 제거 - ALB 헬스체크 사용

# Tempo 실행
CMD ["-config.file=/etc/tempo/tempo.yaml"]
