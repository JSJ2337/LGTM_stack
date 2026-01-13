# Mimir ECS Fargate Dockerfile
# Version: 2.16.0 (EC2 docker-compose 설정 기반)

FROM grafana/mimir:2.16.0

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-mimir"
LABEL version="2.16.0"
LABEL environment="production"

# Tini init 시스템 설치 (Graceful Shutdown)
USER root
RUN apk add --no-cache tini curl

# 설정 파일 복사
COPY config/mimir-config.yaml /etc/mimir/mimir-config.yaml

# 데이터 디렉토리 생성
RUN mkdir -p /var/mimir/tsdb /var/mimir/compactor && \
    chown -R nobody:nogroup /var/mimir

# 비root 유저로 전환
USER nobody

# 환경변수 기본값
ENV AWS_REGION=ap-northeast-2
ENV MIMIR_S3_BUCKET=sys-lgtm-s3

# 포트 노출
EXPOSE 8080 9095 7946

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/-/ready || exit 1

# Tini를 통한 Graceful Shutdown
ENTRYPOINT ["/sbin/tini", "--"]

# Mimir 실행 (ECS Fargate 최적화 옵션 포함)
CMD ["/bin/mimir", \
    "-target=all", \
    "-config.file=/etc/mimir/mimir-config.yaml", \
    "-config.expand-env=true", \
    "-log.level=info", \
    # TSDB 설정
    "-blocks-storage.tsdb.dir=/var/mimir/tsdb", \
    "-blocks-storage.tsdb.retention-period=48h", \
    "-blocks-storage.tsdb.wal-compression-enabled=true", \
    "-blocks-storage.tsdb.flush-blocks-on-shutdown=true", \
    # Compactor 설정
    "-compactor.data-dir=/var/mimir/compactor", \
    "-compactor.compaction-interval=2h", \
    "-compactor.compaction-concurrency=2", \
    # Ring 복제 (3개 Task에서 HA)
    "-ingester.ring.replication-factor=3", \
    "-store-gateway.sharding-ring.replication-factor=3", \
    # Fargate Memberlist 설정 (eth1 인터페이스 사용)
    "-memberlist.bind-port=7946", \
    "-memberlist.advertise-port=7946", \
    # Store-Gateway
    "-blocks-storage.bucket-store.sync-interval=2m", \
    "-blocks-storage.bucket-store.ignore-blocks-within=3h", \
    # Querier
    "-querier.max-outstanding-requests-per-tenant=1024", \
    "-querier.max-concurrent=128", \
    "-querier.timeout=2m", \
    # Query-Frontend
    "-query-frontend.cache-results=false", \
    "-query-frontend.query-sharding-target-series-per-shard=50000", \
    "-query-frontend.log-queries-longer-than=10s"]
