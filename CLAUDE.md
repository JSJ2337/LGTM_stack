# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Grafana LGTM (Loki, Grafana, Tempo, Mimir) 스택 **운영 환경** 설정. 코드 수정은 이 저장소에서 진행.

> **Note**: `LGTM/` 폴더는 레거시 참고용. 실제 운영 코드는 이 `LGTM_PRD/`에서 관리.

## Project Structure

```
LGTM_PRD/
├── alloy/                  # Grafana Alloy (데이터 수집)
│   ├── agent/              # EC2 Agent 설치 스크립트
│   └── container/          # Docker Collector 설정
├── mimir/                  # 메트릭 저장소
├── loki/                   # 로그 저장소
├── tempo/                  # 트레이스 저장소
├── pyroscope/              # 프로파일링
├── grafana/                # 시각화 대시보드
├── aleart/                 # 알림 설정
└── *.json                  # Grafana 대시보드 JSON
```

## Common Commands

### 컴포넌트별 실행

```bash
# Mimir (메트릭)
docker-compose -f mimir/mimir_docker-compose.yaml up -d

# Loki (로그)
docker-compose -f loki/loki_docker-compose.yaml up -d

# Tempo (트레이스)
docker-compose -f tempo/tempo-docker-compose.yaml up -d

# Pyroscope (프로파일링)
docker-compose -f pyroscope/pyroscope-docker-compose.yaml up -d

# Grafana (UI)
docker-compose -f grafana/grafana-docker-compose.yaml up -d

# Alloy Collector
docker-compose -f alloy/container/alloy_multi-docker-compose.yaml up -d
```

### 로그 확인

```bash
docker-compose -f <component>/<compose-file>.yaml logs -f
```

## Architecture

```
                    Grafana (시각화)
                    ↑   ↑   ↑   ↑
          ┌─────────┘   │   │   └─────────┐
          │             │   │             │
       Mimir         Loki  Tempo     Pyroscope
      (메트릭)       (로그) (트레이스) (프로파일)
          ↑             ↑   ↑             ↑
          └──────┬──────┴───┴──────┬──────┘
                 │                 │
         Alloy Agent        Alloy Collector
        (EC2 인스턴스)      (Docker 컨테이너)
              │                    │
        시스템 메트릭         CloudWatch 메트릭
        시스템 로그           CloudWatch 로그
        앱 트레이스           (RDS, ALB, ELB 등)
```

## Alloy Agent 설치

### Linux (Amazon Linux 2023)
```bash
bash alloy/agent/alloy-config_ec2_amz23_only_v5.4.sh
```

### Windows
```powershell
.\alloy\agent\alloy-config_ec2_win_only_v9.2.ps1
```

### Rocky Linux (IDC/오프라인)
```bash
bash alloy/agent/alloy-config_rocky86_offline_v2.2.sh
```

## Tenant IDs

| 수집 대상 | Tenant ID |
|----------|-----------|
| EC2 시스템 메트릭/로그 | `aws-rag-ec2` |
| CloudWatch 메트릭 | `aws-rag-cloudwatch` |
| RDS 로그 | `aws-rag-rds` |

## Storage Backend

모든 백엔드는 S3 버킷 `rag-mimir-pos-s3`에 장기 보관.
