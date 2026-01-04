# LGTM Stack

Docker 기반 통합 관측성(Observability) 플랫폼

## 개요

LGTM Stack은 Loki, Grafana, Tempo, Mimir(또는 Prometheus)로 구성된 완전한 관측성 솔루션입니다.
로그, 메트릭, 트레이스를 통합하여 모니터링, 분석, 알림 기능을 제공하며,
Docker 기반으로 구성되어 쉽게 배포하고 관리할 수 있습니다.

## LGTM Stack 구성 요소

### L - Loki (로그 수집 및 분석)

- 분산 로그 집계 시스템
- Prometheus와 유사한 라벨 기반 로그 저장
- 저비용 로그 관리 솔루션

### G - Grafana (시각화 및 대시보드)

- 통합 모니터링 대시보드
- 로그, 메트릭, 트레이스 통합 시각화
- 알림 및 경보 관리

### T - Tempo (분산 트레이싱)

- 분산 추적 백엔드
- OpenTelemetry, Jaeger, Zipkin 호환
- 마이크로서비스 성능 분석

### M - Mimir (메트릭 저장)

- Prometheus 장기 저장소
- 대규모 메트릭 수집 및 쿼리
- 고가용성 메트릭 스토리지

## 디렉토리 구조

```text
LGTM_stack/
├── loki/                          # Loki 설정 및 구성
├── grafana/                       # Grafana 대시보드 및 설정
├── tempo/                         # Tempo 트레이싱 설정
├── mimir/                         # Mimir 메트릭 저장소 설정
├── pyroscope/                     # Pyroscope 프로파일링
├── alloy/                         # Grafana Alloy (통합 수집기)
├── aleart/                        # 알림 규칙 및 설정
├── ecs-migration/                 # ECS 마이그레이션 관련
├── jenkins_docker/                # Jenkins Docker 통합
├── 1. FTT_AWS_IDC_server_resource-dashboard-*.json
└── 2. FTT_AWS_RDS_Elasticache_Database-dashboard-*.json
```

## 주요 기능

### 1. 통합 로그 관리 (Loki)

- 애플리케이션 로그 수집
- 시스템 로그 집계
- 로그 쿼리 및 검색 (LogQL)
- 로그 기반 메트릭 생성

### 2. 메트릭 모니터링 (Mimir/Prometheus)

- 시스템 리소스 메트릭
- 애플리케이션 성능 메트릭
- 커스텀 메트릭 수집
- 장기 메트릭 저장

### 3. 분산 트레이싱 (Tempo)

- 마이크로서비스 간 요청 추적
- 성능 병목 지점 식별
- 서비스 의존성 시각화
- OpenTelemetry 통합

### 4. 대시보드 및 시각화 (Grafana)

- AWS 인프라 모니터링 대시보드
- RDS 및 ElastiCache 모니터링
- 커스텀 대시보드 생성
- 알림 및 경보 설정

### 5. 프로파일링 (Pyroscope)

- 애플리케이션 CPU/메모리 프로파일링
- 성능 최적화 분석
- 연속적인 프로파일링

## 설치 및 실행

### 사전 요구사항

- Docker 및 Docker Compose
- 최소 4GB RAM 권장
- 충분한 디스크 공간 (로그 저장용)

### Docker Compose로 실행

```bash
# LGTM Stack 전체 실행
docker-compose up -d

# 특정 서비스만 실행
docker-compose up -d grafana loki

# 로그 확인
docker-compose logs -f grafana

# 중지
docker-compose down
```

### 접속 정보

- **Grafana**: `http://localhost:3000`
- **Loki**: `http://localhost:3100`
- **Tempo**: `http://localhost:3200`
- **Mimir**: `http://localhost:9009`

## 데이터 소스 설정

### Grafana에서 데이터 소스 추가

```yaml
Loki:
  url: http://loki:3100

Prometheus/Mimir:
  url: http://mimir:9009/prometheus

Tempo:
  url: http://tempo:3200
```

## 대시보드

### 사전 구성된 대시보드

1. **AWS IDC Server Resource Dashboard**
   - EC2 인스턴스 모니터링
   - CPU, 메모리, 디스크, 네트워크
   - 인스턴스 상태 및 경보

2. **AWS RDS & ElastiCache Dashboard**
   - RDS 성능 메트릭
   - ElastiCache 모니터링
   - 데이터베이스 연결 상태

### 대시보드 Import

```bash
# Grafana UI에서
1. Configuration → Data Sources → Import
2. JSON 파일 업로드 또는 ID 입력
3. 데이터 소스 선택
4. Import
```

## Grafana Alloy

Grafana Alloy는 OpenTelemetry Collector 기반의 통합 수집기입니다.

- 로그, 메트릭, 트레이스 통합 수집
- 다양한 데이터 소스 지원
- 동적 설정 및 파이프라인 구성

## 알림 설정

알림 규칙은 `aleart/` 디렉토리에서 관리합니다.

### 알림 채널

- Email
- Slack
- PagerDuty
- Webhook

## ECS 마이그레이션

ECS 환경으로 마이그레이션하는 경우 `ecs-migration/` 디렉토리를 참고하세요.

- ECS Task Definition
- Service 설정
- 로드 밸런서 구성

## 보안 고려사항

- Grafana 기본 비밀번호 변경 필수
- HTTPS 사용 권장 (프로덕션 환경)
- 네트워크 접근 제한 (방화벽, 보안 그룹)
- 민감한 데이터 암호화

## 트러블슈팅

### Loki 로그 수집 안됨

```bash
# Loki 상태 확인
curl http://localhost:3100/ready

# Loki 로그 확인
docker logs loki
```

### Grafana 데이터 소스 연결 실패

```bash
# 네트워크 확인
docker network ls
docker network inspect lgtm_network

# 서비스 간 통신 확인
docker exec -it grafana ping loki
```

### 디스크 공간 부족

```bash
# 로그 보관 기간 설정
# loki-config.yaml에서 retention 설정 조정
```

## 모니터링 모범 사례

1. **로그 레벨 적절히 설정**: DEBUG는 개발 환경에서만
2. **메트릭 수집 주기 조정**: 너무 짧으면 부하 증가
3. **알림 임계값 설정**: False Positive 최소화
4. **대시보드 정리**: 필요한 메트릭만 표시
5. **정기적인 백업**: Grafana 대시보드 및 설정

## 참고 자료

- [Grafana Loki Documentation](https://grafana.com/docs/loki/)
- [Grafana Tempo Documentation](https://grafana.com/docs/tempo/)
- [Grafana Mimir Documentation](https://grafana.com/docs/mimir/)
- [Grafana Documentation](https://grafana.com/docs/grafana/)

## 라이선스

Private Repository

## 기여

내부 사용 목적의 Private 저장소입니다.
