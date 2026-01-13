# LGTM Stack ECS Fargate Migration

EC2 기반 LGTM 스택을 ECS Fargate로 마이그레이션하기 위한 설정 파일 모음

## 폴더 구조

```text
ecs-migration/
├── README.md                    # 이 파일
├── docs/                        # 문서
│   ├── architecture.md          # 아키텍처 설계
│   ├── migration-plan.md        # 마이그레이션 계획
│   ├── troubleshooting.md       # 트러블슈팅 가이드
│   └── work_history/            # 작업 이력
├── task-definitions/            # ECS Task Definition
│   ├── mimir.json
│   ├── loki.json
│   ├── tempo.json
│   ├── pyroscope.json
│   ├── grafana.json
│   └── alloy.json
├── dockerfiles/                 # Dockerfile
│   ├── mimir/
│   ├── loki/
│   ├── tempo/
│   ├── pyroscope/
│   ├── grafana/
│   └── alloy/
├── .github/workflows/           # GitHub Actions CI/CD
│   ├── deploy-ecs.yaml          # ECS 배포 워크플로우
│   ├── terraform.yaml           # Terraform 워크플로우
│   └── build-only.yaml          # PR 빌드 테스트
├── terraform/                   # Terraform IaC
│   ├── modules/
│   │   ├── ecr/                 # ECR 리포지토리
│   │   ├── iam/                 # IAM 역할
│   │   ├── security-groups/     # 보안 그룹
│   │   ├── cloudmap/            # Service Discovery
│   │   ├── alb/                 # Application Load Balancer
│   │   └── ecs/                 # ECS Cluster & Services
│   └── environments/
│       └── prod/                # Production 환경
└── scripts/                     # 유틸리티 스크립트
    ├── build-all.sh             # 전체 이미지 빌드
    ├── deploy-ecs.sh            # ECS 배포
    └── setup-infrastructure.sh  # 인프라 초기 설정
```

## 빠른 시작

### 1. 인프라 사전 설정

```bash
# ECR, CloudWatch Log Groups, Secrets Manager 생성
./scripts/setup-infrastructure.sh
```

### 2. Terraform으로 인프라 생성

```bash
cd terraform/environments/prod

# terraform.tfvars 설정
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars 수정

# 인프라 생성
terraform init
terraform plan
terraform apply
```

### 3. Docker 이미지 빌드 및 푸시

```bash
./scripts/build-all.sh latest
```

### 4. ECS 서비스 배포

```bash
./scripts/deploy-ecs.sh all
```

## GitHub Actions CI/CD

### 자동 배포 (Push to main)

`main` 또는 `lgtm_prd` 브랜치에 푸시하면 자동으로 빌드 및 배포됩니다.

### 수동 배포 (Workflow Dispatch)

GitHub Actions에서 수동으로 특정 컴포넌트만 배포할 수 있습니다.

1. GitHub Repository > Actions > Deploy LGTM Stack to ECS
2. Run workflow 클릭
3. 컴포넌트 선택 (all/mimir/loki/tempo/pyroscope/grafana/alloy)
4. Run workflow 실행

### 필요한 GitHub Secrets

```text
AWS_ROLE_ARN        # OIDC 인증용 IAM Role ARN
SLACK_WEBHOOK_URL   # (선택) Slack 알림 URL
```

## 마이그레이션 체크리스트

### Phase 1: 준비 (1일)

- [ ] AWS IAM OIDC Provider 설정 (GitHub Actions용)
- [ ] ECR 리포지토리 생성 (6개)
- [ ] VPC, Subnet, Security Group 확인
- [ ] IAM Role 생성 (TaskExecutionRole, TaskRole)
- [ ] S3 버킷 권한 확인
- [ ] Secrets Manager 시크릿 생성

### Phase 2: Terraform 인프라 생성 (2일)

- [ ] terraform.tfvars 설정
- [ ] terraform plan 검증
- [ ] terraform apply 실행
- [ ] ECS Cluster 생성 확인
- [ ] CloudMap Namespace 생성 확인
- [ ] ALB 생성 확인

### Phase 3: Docker 이미지 빌드 (1일)

- [ ] Mimir 이미지 빌드 및 푸시
- [ ] Loki 이미지 빌드 및 푸시
- [ ] Tempo 이미지 빌드 및 푸시
- [ ] Pyroscope 이미지 빌드 및 푸시
- [ ] Grafana 이미지 빌드 및 푸시
- [ ] Alloy 이미지 빌드 및 푸시

### Phase 4: 배포 및 테스트 (3일)

- [ ] 각 서비스 배포
- [ ] Service Discovery 동작 확인
- [ ] 데이터 수집 테스트
- [ ] S3 저장 확인
- [ ] Grafana 대시보드 확인

### Phase 5: 트래픽 전환 (1일)

- [ ] DNS 전환
- [ ] 모니터링 확인
- [ ] 롤백 계획 준비
- [ ] 기존 EC2 백업

## 주요 설정

### Fargate 필수 설정

**Memberlist (Mimir/Loki):**

```yaml
memberlist:
  bind_addr: "0.0.0.0"
  bind_port: 7946
  join_members:
    - "mimir.lgtm.local:7946"
```

**Graceful Shutdown:**

```json
{
  "stopTimeout": 120
}
```

### Service Discovery

**CloudMap Namespace:** `lgtm.local` (Private DNS)

**Service Endpoints:**

- `mimir.lgtm.local:8080`
- `loki.lgtm.local:3100`
- `tempo.lgtm.local:3200`
- `pyroscope.lgtm.local:4040`
- `grafana.lgtm.local:3000`

## 리소스 할당

| 컴포넌트 | Task 수 | vCPU | Memory | 월 예상 비용 |
|----------|---------|------|--------|--------------|
| Mimir | 3 | 2 | 4GB | ~$270 |
| Loki | 2 | 1 | 2GB | ~$120 |
| Tempo | 1 | 1 | 2GB | ~$60 |
| Pyroscope | 1 | 1 | 2GB | ~$60 |
| Grafana | 1 | 0.5 | 1GB | ~$25 |
| Alloy | 1 | 0.5 | 1GB | ~$25 |
| **합계** | - | - | - | **~$560/월** |

## 참고 자료

- [Grafana Loki/Tempo on AWS Fargate](https://grafana.com/blog/2021/08/11/a-guide-to-deploying-grafana-loki-and-grafana-tempo-without-kubernetes-on-aws-fargate/)
- [Mimir on ECS Fargate Discussion](https://github.com/grafana/mimir/discussions/3807)
- [AWS Samples: Grafana Stack](https://github.com/aws-samples/sample-grafana-prometheus-stack)
- [GitHub Actions OIDC with AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)

## 주의사항

1. **Fargate는 eBPF 미지원** - Beyla 사용 불가
2. **EC2 시스템 메트릭 수집 방법 변경 필요**
3. **Memberlist 설정 필수** - 클러스터링용
4. **stopTimeout 120초 설정** - Graceful Shutdown 보장
5. **GitHub Actions OIDC 설정 필요** - CI/CD용

---

**Last Updated:** 2026-01-13
**Status:** 구현 완료
