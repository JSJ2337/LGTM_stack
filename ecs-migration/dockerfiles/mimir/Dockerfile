# Mimir ECS Fargate Dockerfile
# Version: 2.16.0 (EC2 docker-compose 설정 기반)

FROM grafana/mimir:2.16.0

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-mimir"
LABEL version="2.16.0"
LABEL environment="production"

# 설정 파일 복사 (Distroless 이미지는 shell 없음, COPY만 가능)
COPY config/mimir-config.yaml /etc/mimir/mimir-config.yaml

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV MIMIR_S3_BUCKET=sys-lgtm-s3

# 포트 노출
EXPOSE 8080 9095 7946

# 헬스체크 비활성화 (Distroless에서는 wget/curl 없음, ECS Task Definition에서 설정)
# HEALTHCHECK 제거 - ALB 헬스체크 사용

# Mimir 실행 (ECS Fargate 최적화 옵션 포함)
CMD ["/bin/mimir", \
    "-target=all", \
    "-config.file=/etc/mimir/mimir-config.yaml", \
    "-config.expand-env=true", \
    "-log.level=info", \
    "-blocks-storage.tsdb.dir=/var/mimir/tsdb", \
    "-blocks-storage.tsdb.retention-period=48h", \
    "-blocks-storage.tsdb.wal-compression-enabled=true", \
    "-blocks-storage.tsdb.flush-blocks-on-shutdown=true", \
    "-compactor.data-dir=/var/mimir/compactor", \
    "-compactor.compaction-interval=2h", \
    "-compactor.compaction-concurrency=2", \
    "-ingester.ring.replication-factor=3", \
    "-store-gateway.sharding-ring.replication-factor=3", \
    "-memberlist.bind-port=7946", \
    "-memberlist.advertise-port=7946", \
    "-blocks-storage.bucket-store.sync-interval=2m", \
    "-blocks-storage.bucket-store.ignore-blocks-within=3h", \
    "-querier.max-outstanding-requests-per-tenant=1024", \
    "-querier.max-concurrent=128", \
    "-querier.timeout=2m", \
    "-query-frontend.cache-results=false", \
    "-query-frontend.query-sharding-target-series-per-shard=50000", \
    "-query-frontend.log-queries-longer-than=10s"]
