# Tempo ECS Fargate Dockerfile
# Version: 2.7.2 (EC2 docker-compose 설정 기반)

FROM grafana/tempo:2.7.2

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-tempo"
LABEL version="2.7.2"
LABEL environment="production"

# 설정 파일 복사
USER root
COPY config/tempo-config.yaml /etc/tempo/tempo.yaml

# 데이터 디렉토리 생성
RUN mkdir -p /var/tempo/generator-wal && \
    chown -R 10001:10001 /var/tempo

# 비root 유저로 전환
USER 10001

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2

# 포트 노출
EXPOSE 3200 4317 4318

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3200/ready || exit 1

# Tempo 실행
CMD ["/tempo", "-config.file=/etc/tempo/tempo.yaml"]
