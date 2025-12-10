# LGTM Stack ECS Fargate Architecture

## 전체 아키텍처

```
                    ┌───────────────────────────┐
                    │   Application Users       │
                    └────────────┬──────────────┘
                                 │
                                 ▼
                    ┌───────────────────────────┐
                    │  Application Load Balancer│
                    │  - grafana.example.com    │
                    └────────────┬──────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│    Grafana      │  │  Data Sources   │  │   Collectors    │
│   (Fargate)     │  │                 │  │                 │
│   - :3000       │  │                 │  │  Alloy          │
└─────────────────┘  │                 │  │  (Fargate)      │
                     │                 │  │  - CloudWatch   │
                     ▼                 │  │  - OTLP         │
        ┌────────────────────────┐    │  └────────┬────────┘
        │   Mimir (Metrics)      │◄───┤           │
        │   - 3x Fargate Tasks   │    │           │
        │   - Monolith mode      │    │           │
        │   - S3: blocks/        │    │           │
        └────────────────────────┘    │           │
                                      │           │
        ┌────────────────────────┐    │           │
        │   Loki (Logs)          │◄───┤───────────┘
        │   - Distributor        │    │
        │   - Ingester           │    │
        │   - Querier            │    │
        │   - S3: ftt-loki/      │    │
        └────────────────────────┘    │
                                      │
        ┌────────────────────────┐    │
        │   Tempo (Traces)       │◄───┘
        │   - Distributor        │
        │   - Ingester           │
        │   - Querier            │
        │   - S3: ftt-tempo/     │
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Pyroscope (Profiles) │
        │   - All-in-one         │
        │   - S3: ftt-pyroscope/ │
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   AWS CloudMap         │
        │   (Service Discovery)  │
        │  - mimir.lgtm.local    │
        │  - loki.lgtm.local     │
        │  - tempo.lgtm.local    │
        └────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   S3 Bucket            │
        │   sys-lgtm-s3          │
        └────────────────────────┘
```

## 네트워크 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC                                  │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │               Public Subnet (AZ-A)                     │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Application Load Balancer                        │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                  │
│  ┌────────────────────────┼──────────────────────────────┐  │
│  │               Private Subnet (AZ-A)                   │  │
│  │                        │                              │  │
│  │  ┌─────────────────────┴─────────────────────┐       │  │
│  │  │        ECS Fargate Tasks                  │       │  │
│  │  │  - Mimir (3 tasks)                        │       │  │
│  │  │  - Loki (2 tasks)                         │       │  │
│  │  │  - Tempo (1 task)                         │       │  │
│  │  │  - Pyroscope (1 task)                     │       │  │
│  │  │  - Grafana (1 task)                       │       │  │
│  │  │  - Alloy (1 task)                         │       │  │
│  │  └───────────────────────────────────────────┘       │  │
│  │                        │                              │  │
│  │                        ▼                              │  │
│  │  ┌──────────────────────────────────────────┐        │  │
│  │  │  AWS CloudMap (lgtm.local)               │        │  │
│  │  └──────────────────────────────────────────┘        │  │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                  │
│  ┌────────────────────────┼──────────────────────────────┐  │
│  │               Private Subnet (AZ-B)                   │  │
│  │                        │                              │  │
│  │  ┌─────────────────────┴─────────────────────┐       │  │
│  │  │        ECS Fargate Tasks (HA)             │       │  │
│  │  └───────────────────────────────────────────┘       │  │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                  │
│                           ▼                                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              NAT Gateway                              │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │  Internet Gateway     │
                └───────────────────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │   Internet    │
                    └───────────────┘
```

## 데이터 플로우

### 1. Metrics Flow

```
Application
    │
    ▼ (Prometheus Remote Write)
Alloy Collector (Fargate)
    │
    ▼
Mimir Distributor (Fargate)
    │
    ▼
Mimir Ingester (Fargate)
    │
    ▼ (Flush every 2h or shutdown)
S3 Bucket (sys-lgtm-s3/blocks/)
    │
    ▼ (Query)
Mimir Querier (Fargate)
    │
    ▼
Grafana (Fargate)
```

### 2. Logs Flow

```
Application
    │
    ▼ (Loki Push API)
Alloy Collector (Fargate)
    │
    ▼
Loki Distributor (Fargate)
    │
    ▼
Loki Ingester (Fargate)
    │
    ▼ (Flush chunks)
S3 Bucket (sys-lgtm-s3/ftt-loki/)
    │
    ▼ (Query)
Loki Querier (Fargate)
    │
    ▼
Grafana (Fargate)
```

### 3. Traces Flow

```
Application (OpenTelemetry)
    │
    ▼ (OTLP gRPC/HTTP)
Tempo Distributor (Fargate)
    │
    ▼
Tempo Ingester (Fargate)
    │
    ▼ (Flush blocks)
S3 Bucket (sys-lgtm-s3/ftt-tempo/)
    │
    ▼ (Query)
Tempo Querier (Fargate)
    │
    ▼
Grafana (Fargate)
```

## 컴포넌트 상세

### Mimir

**배포 모드:** Monolith (단일 바이너리)
**인스턴스 수:** 3 (HA)
**리소스:** 2 vCPU, 4GB Memory

**주요 설정:**
- Memberlist로 클러스터링
- S3 백엔드 (blocks, ruler, alertmanager)
- 1년 보존 정책

### Loki

**배포 모드:** Microservices (Distributor, Ingester, Querier)
**인스턴스 수:** 2 (Distributor/Ingester/Querier 각각)
**리소스:** 1 vCPU, 2GB Memory

**주요 설정:**
- TSDB v13 스키마
- S3 백엔드
- Memcached 캐시
- 1년 보존 (info 로그 30일)

### Tempo

**배포 모드:** Microservices
**인스턴스 수:** 1 (각 컴포넌트)
**리소스:** 1 vCPU, 2GB Memory

**주요 설정:**
- OTLP 수신 (gRPC :4317, HTTP :4318)
- S3 백엔드
- 7일 보존
- Metrics Generator → Mimir 연동

### Pyroscope

**배포 모드:** All-in-one
**인스턴스 수:** 1
**리소스:** 1 vCPU, 2GB Memory

**주요 설정:**
- S3 백엔드
- 30일 보존

### Grafana

**배포 모드:** Standalone
**인스턴스 수:** 1
**리소스:** 0.5 vCPU, 1GB Memory

**데이터 소스:**
- Mimir (Prometheus)
- Loki
- Tempo
- Pyroscope

### Alloy Collector

**배포 모드:** Collector (CloudWatch 수집)
**인스턴스 수:** 1
**리소스:** 0.5 vCPU, 1GB Memory

**수집 대상:**
- CloudWatch Metrics (RDS, ALB, NLB, ElastiCache)
- CloudWatch Logs
- ECS Container Insights

## Service Discovery (AWS CloudMap)

**Namespace:** `lgtm.local` (Private DNS)

**Services:**
```
mimir.lgtm.local:9009       → Mimir Tasks (3개)
loki.lgtm.local:3100        → Loki Tasks (2개)
tempo.lgtm.local:3200       → Tempo Tasks (1개)
pyroscope.lgtm.local:4040   → Pyroscope Task (1개)
grafana.lgtm.local:3000     → Grafana Task (1개)
```

## Load Balancing

**Application Load Balancer:**

**Listener Rules (Port 443):**
```
grafana.example.com/*              → Grafana Target Group
mimir.example.com/api/v1/push      → Mimir Target Group
loki.example.com/loki/api/v1/push  → Loki Target Group
tempo.example.com/api/traces       → Tempo Target Group
```

**Target Groups:**
- Grafana TG → Port 3000
- Mimir TG → Port 9009
- Loki TG → Port 3100
- Tempo TG → Port 3200

## Security Groups

### ALB Security Group
```
Inbound:
- 443/tcp from 0.0.0.0/0 (HTTPS)
- 80/tcp from 0.0.0.0/0 (HTTP → HTTPS redirect)

Outbound:
- All traffic
```

### ECS Tasks Security Group
```
Inbound:
- 3000/tcp from ALB SG (Grafana)
- 9009/tcp from ALB SG + Self (Mimir)
- 3100/tcp from ALB SG + Self (Loki)
- 3200/tcp from ALB SG + Self (Tempo)
- 4317/tcp from ALB SG (Tempo OTLP gRPC)
- 4318/tcp from ALB SG (Tempo OTLP HTTP)
- 7946/tcp from Self (Memberlist)

Outbound:
- All traffic
```

## Storage (S3)

**Bucket:** `sys-lgtm-s3` (ap-northeast-2)

**구조:**
```
sys-lgtm-s3/
├── blocks/              # Mimir 메트릭 블록
├── rules/               # Mimir 알람 룰
├── alerts/              # Mimir Alertmanager 상태
├── ftt-loki/            # Loki 로그 인덱스/청크
├── ftt-tempo/           # Tempo 트레이스 블록
└── ftt-pyroscope/       # Pyroscope 프로파일
```

**Lifecycle Policy:**
- Standard → Infrequent Access (30일)
- Infrequent Access → Glacier (90일)
- Glacier → 삭제 (1년)

## IAM Roles

### Task Execution Role
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### Task Role (Mimir/Loki/Tempo/Pyroscope)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::sys-lgtm-s3",
        "arn:aws:s3:::sys-lgtm-s3/*"
      ]
    }
  ]
}
```

### Task Role (Alloy Collector)
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:GetMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics",
        "logs:GetLogEvents",
        "logs:FilterLogEvents",
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
```

## 모니터링

### CloudWatch Logs

**Log Groups:**
```
/ecs/lgtm-mimir
/ecs/lgtm-loki
/ecs/lgtm-tempo
/ecs/lgtm-pyroscope
/ecs/lgtm-grafana
/ecs/lgtm-alloy
```

**보존 기간:** 7일

### CloudWatch Metrics

**Container Insights 활성화:**
```
aws ecs update-cluster-settings \
  --cluster lgtm-cluster \
  --settings name=containerInsights,value=enabled
```

**수집 메트릭:**
- CPU 사용률
- 메모리 사용률
- 네트워크 I/O
- 디스크 I/O

## 비용 최적화

### Fargate Spot 사용 (선택)

**적용 대상:**
- Querier (상태 비저장)
- Query Frontend

**예상 절감:** ~70%

### S3 Intelligent-Tiering

자동으로 액세스 패턴에 따라 스토리지 클래스 변경

### CloudWatch Logs 보존 기간 단축

불필요한 로그는 7일 후 삭제

---

**Last Updated:** 2025-12-10
