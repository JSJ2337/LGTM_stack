# LGTM Stack ECS Fargate Migration

EC2 기반 LGTM 스택을 ECS Fargate로 마이그레이션하기 위한 설정 파일 모음

## 📁 폴더 구조

```text
ecs-migration/
├── README.md                    # 이 파일
├── docs/                        # 문서
│   ├── architecture.md          # 아키텍처 설계
│   ├── migration-plan.md        # 마이그레이션 계획
│   └── troubleshooting.md       # 트러블슈팅 가이드
├── task-definitions/            # ECS Task Definition
│   ├── mimir.json
│   ├── loki.json
│   ├── tempo.json
│   ├── pyroscope.json
│   ├── grafana.json
│   └── alloy-collector.json
├── dockerfiles/                 # Dockerfile
│   ├── mimir/
│   ├── loki/
│   ├── tempo/
│   ├── pyroscope/
│   ├── grafana/
│   └── alloy/
├── jenkins/                     # Jenkins CI/CD
│   ├── Jenkinsfile
│   └── scripts/
└── terraform/                   # Terraform IaC (선택)
    ├── main.tf
    ├── variables.tf
    └── modules/
```

## 🚀 빠른 시작

### 1. ECR 리포지토리 생성

```bash
aws ecr create-repository --repository-name lgtm-mimir --region ap-northeast-2
aws ecr create-repository --repository-name lgtm-loki --region ap-northeast-2
aws ecr create-repository --repository-name lgtm-tempo --region ap-northeast-2
aws ecr create-repository --repository-name lgtm-pyroscope --region ap-northeast-2
aws ecr create-repository --repository-name lgtm-grafana --region ap-northeast-2
aws ecr create-repository --repository-name lgtm-alloy --region ap-northeast-2
```

### 2. Docker 이미지 빌드 & 푸시

```bash
# Mimir 예시
cd dockerfiles/mimir
docker build -t lgtm-mimir:latest .
docker tag lgtm-mimir:latest <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/lgtm-mimir:latest
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com
docker push <account-id>.dkr.ecr.ap-northeast-2.amazonaws.com/lgtm-mimir:latest
```

### 3. ECS Task Definition 등록

```bash
aws ecs register-task-definition --cli-input-json file://task-definitions/mimir.json
```

### 4. ECS 서비스 생성

```bash
aws ecs create-service \
  --cluster lgtm-cluster \
  --service-name mimir \
  --task-definition lgtm-mimir \
  --desired-count 3 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx]}"
```

## 📋 마이그레이션 체크리스트

### Phase 1: 준비 (1일)

- [ ] ECR 리포지토리 생성
- [ ] VPC, Subnet, Security Group 확인
- [ ] IAM Role 생성 (TaskExecutionRole, TaskRole)
- [ ] S3 버킷 권한 확인

### Phase 2: Dockerfile 작성 (2일)

- [ ] Mimir Dockerfile
- [ ] Loki Dockerfile
- [ ] Tempo Dockerfile
- [ ] Pyroscope Dockerfile
- [ ] Grafana Dockerfile
- [ ] Alloy Dockerfile

### Phase 3: Task Definition 작성 (2일)

- [ ] Mimir Task Definition
- [ ] Loki Task Definition
- [ ] Tempo Task Definition
- [ ] Pyroscope Task Definition
- [ ] Grafana Task Definition
- [ ] Alloy Task Definition

### Phase 4: 인프라 구성 (3일)

- [ ] ECS Cluster 생성
- [ ] AWS CloudMap (Service Discovery) 설정
- [ ] Application Load Balancer 설정
- [ ] Target Group 생성
- [ ] ALB Listener Rule 설정

### Phase 5: 배포 테스트 (2일)

- [ ] 각 서비스 배포
- [ ] Service Discovery 동작 확인
- [ ] 데이터 수집 테스트
- [ ] S3 저장 확인

### Phase 6: Jenkins CI/CD (2일)

- [ ] Jenkinsfile 작성
- [ ] ECR 푸시 자동화
- [ ] ECS 배포 자동화
- [ ] 파이프라인 테스트

### Phase 7: 트래픽 전환 (1일)

- [ ] Blue/Green 배포 설정
- [ ] DNS 전환
- [ ] 모니터링 확인
- [ ] 롤백 계획 준비

## 🔧 주요 설정

### Fargate 필수 설정

**Memberlist (Mimir/Loki/Tempo):**

```yaml
memberlist:
  interface_names: ["eth1"]  # Fargate 1.4.0+ 필수
```

**Graceful Shutdown:**

```json
{
  "stopTimeout": 120
}
```

### Service Discovery

**CloudMap Namespace:**

- `lgtm.local` (Private DNS)

**Service Endpoints:**

- `mimir.lgtm.local:9009`
- `loki.lgtm.local:3100`
- `tempo.lgtm.local:3200`
- `pyroscope.lgtm.local:4040`
- `grafana.lgtm.local:3000`

## 📊 리소스 할당

| 컴포넌트 | Task 수 | vCPU | Memory | 월 예상 비용 |
|----------|---------|------|--------|--------------|
| Mimir | 3 | 2 | 4GB | ~$270 |
| Loki | 2 | 1 | 2GB | ~$120 |
| Tempo | 1 | 1 | 2GB | ~$60 |
| Pyroscope | 1 | 1 | 2GB | ~$60 |
| Grafana | 1 | 0.5 | 1GB | ~$25 |
| Alloy | 1 | 0.5 | 1GB | ~$25 |
| **합계** | - | - | - | **~$560/월** |

## 🔗 참고 자료

- [Grafana Loki/Tempo on AWS Fargate](https://grafana.com/blog/2021/08/11/a-guide-to-deploying-grafana-loki-and-grafana-tempo-without-kubernetes-on-aws-fargate/)
- [Mimir on ECS Fargate Discussion](https://github.com/grafana/mimir/discussions/3807)
- [AWS Samples: Grafana Stack](https://github.com/aws-samples/sample-grafana-prometheus-stack)
- [Jenkins + ECR + ECS](https://aws.amazon.com/blogs/devops/set-up-a-build-pipeline-with-jenkins-and-amazon-ecs/)

## ⚠️ 주의사항

1. **Fargate는 eBPF 미지원** → Beyla 사용 불가
2. **EC2 시스템 메트릭 수집 방법 변경 필요**
3. **Memberlist interface_names: ["eth1"] 필수**
4. **stopTimeout 120초 설정으로 Graceful Shutdown 보장**

---

**Last Updated:** 2025-12-10
**Status:** 준비 단계
