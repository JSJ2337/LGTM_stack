# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Code Guidelines

**재사용성을 최우선으로 고려**: 모든 코드는 재사용 가능하도록 작성해야 합니다. 하드코딩을 지양하고, 설정 파일이나 환경 변수를 활용하며, 모듈화된 구조를 유지합니다.

**문서 동기화 필수**: 코드 수정, 업데이트, 추가 등 코드 관련 작업이나 정보가 변경되면 반드시 `docs/` 폴더 내의 관련 문서도 함께 업데이트해야 합니다. 코드와 문서의 불일치를 방지합니다.

**Markdown 작성 규칙**: 모든 Markdown 문서는 markdownlint 규칙을 준수해야 합니다. 일관된 문서 품질을 유지합니다.

## Repository Overview

Grafana LGTM (Loki, Grafana, Tempo, Mimir) 스택 **운영 환경** 설정. 코드 수정은 이 저장소에서 진행.

> **Note**: `LGTM/` 폴더는 레거시 참고용. 실제 운영 코드는 이 `LGTM_PRD/`에서 관리.

## Project Structure

```text
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
├── jenkins_docker/         # Jenkins CI/CD 환경
│   ├── Dockerfile          # Jenkins + Terraform + Terragrunt + gcloud
│   ├── jsj_jenkins.yaml    # Jenkins 컨테이너 설정
│   ├── jsj_ngrok.yaml      # ngrok 외부 접속 설정
│   └── README.md           # Jenkins 설정 가이드
├── ecs-migration/          # ECS Fargate 마이그레이션 문서
│   ├── README.md           # 마이그레이션 개요
│   └── docs/               # 상세 문서 (architecture, plan, troubleshooting)
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

```text
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

## Jenkins CI/CD

### Jenkins 실행 (로컬)

```bash
cd jenkins_docker
docker-compose -f jsj_jenkins.yaml up -d --build
```

- 접속: <http://localhost:8080>
- 초기 비밀번호: `docker exec jsj-jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword`

### Jenkins + ngrok (외부 접속)

```bash
cd jenkins_docker

# 1. .env 파일 생성 및 NGROK_AUTHTOKEN 설정

cp .env.example .env

# 2. Jenkins 실행

docker-compose -f jsj_jenkins.yaml up -d --build

# 3. ngrok 실행

docker-compose -f jsj_ngrok.yaml up -d

# 4. ngrok URL 확인

docker logs jsj-jenkins-ngrok | grep "started tunnel"
```

**설치된 도구**:

- Jenkins LTS (latest with JDK 17)
- Terraform 1.13.5 (Multi-arch: ARM64/AMD64)
- Terragrunt 0.93.3 (Multi-arch: ARM64/AMD64)
- Google Cloud SDK (gcloud)
- Jenkins CLI
- Git, Python 3

**Jenkins CLI 사용**:

```bash
docker exec jsj-jenkins-server java -jar /usr/local/bin/jenkins-cli.jar -s http://localhost:8080/ -auth admin:PASSWORD help
```

**Jenkins REST API**:

- Base URL: <http://localhost:8080> 또는 ngrok URL
- Authentication: API Token (User → Configure → API Token)
- Example: `curl -u username:token http://localhost:8080/api/json`

## ECS Fargate Migration

ECS Fargate로 마이그레이션 문서는 `ecs-migration/` 폴더 참조:

- [README.md](ecs-migration/README.md): 프로젝트 개요 및 빠른 시작
- [docs/architecture.md](ecs-migration/docs/architecture.md): 상세 아키텍처
- [docs/migration-plan.md](ecs-migration/docs/migration-plan.md): 14일 마이그레이션 계획
- [docs/troubleshooting.md](ecs-migration/docs/troubleshooting.md): 트러블슈팅 가이드
