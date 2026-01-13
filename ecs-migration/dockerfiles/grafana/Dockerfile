# Grafana ECS Fargate Dockerfile
# Version: 12.1.0 (EC2 docker-compose 설정 기반)

FROM grafana/grafana:12.1.0

# 메타데이터
LABEL maintainer="jsj"
LABEL app="lgtm-grafana"
LABEL version="12.1.0"
LABEL environment="production"

# root 유저로 전환하여 패키지 설치
USER root
RUN apk add --no-cache tini curl

# 프로비저닝 디렉토리 생성
RUN mkdir -p /etc/grafana/provisioning/datasources \
             /etc/grafana/provisioning/dashboards \
             /var/lib/grafana/dashboards

# 프로비저닝 설정 파일 복사
COPY config/provisioning/ /etc/grafana/provisioning/

# 권한 설정
RUN chown -R grafana:root /etc/grafana /var/lib/grafana

# 비root 유저로 전환
USER grafana

# 환경변수 기본값
ENV GF_SECURITY_ADMIN_USER=admin
ENV GF_USERS_ALLOW_SIGN_UP=false
ENV GF_LOG_LEVEL=info
ENV GF_DATE_FORMATS_DEFAULT_TIMEZONE=Asia/Seoul
ENV TZ=Asia/Seoul
ENV GF_INSTALL_PLUGINS=grafana-piechart-panel
ENV GF_FEATURE_TOGGLES_ENABLE=alertingCentralAlertHistory
ENV GF_UNIFIED_ALERTING_STATE_HISTORY_ENABLED=true
ENV GF_UNIFIED_ALERTING_STATE_HISTORY_BACKEND=loki
ENV GF_UNIFIED_ALERTING_STATE_HISTORY_LOKI_REMOTE_URL=http://loki.lgtm.local:3100
ENV GF_UNIFIED_ALERTING_STATE_HISTORY_LOKI_TENANT_ID=ftt-lgtm

# 포트 노출
EXPOSE 3000

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/health || exit 1

# Tini를 통한 Graceful Shutdown
ENTRYPOINT ["/sbin/tini", "--"]

# Grafana 실행
CMD ["/run.sh"]
