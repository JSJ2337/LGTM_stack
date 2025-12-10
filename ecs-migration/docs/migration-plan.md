# LGTM Stack ECS Fargate Migration Plan

## 마이그레이션 개요

**목표:** EC2 기반 LGTM 스택을 ECS Fargate로 전환하여 관리 부담 감소 및 자동화 강화

**예상 기간:** 2주 (10 영업일)

**작업자:** DevOps 팀

---

## Phase 1: 준비 단계 (Day 1)

### 1.1 AWS 리소스 사전 준비

**ECR 리포지토리 생성:**
```bash
#!/bin/bash
REGION="ap-northeast-2"
REPOS=("lgtm-mimir" "lgtm-loki" "lgtm-tempo" "lgtm-pyroscope" "lgtm-grafana" "lgtm-alloy")

for repo in "${REPOS[@]}"; do
  aws ecr create-repository \
    --repository-name $repo \
    --region $REGION \
    --image-scanning-configuration scanOnPush=true
done
```

**IAM Role 생성:**
```bash
# Task Execution Role
aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy

# Task Role (S3 Access)
aws iam create-role \
  --role-name lgtmTaskRole \
  --assume-role-policy-document file://trust-policy.json

aws iam put-role-policy \
  --role-name lgtmTaskRole \
  --policy-name S3Access \
  --policy-document file://s3-policy.json
```

**S3 버킷 권한 확인:**
```bash
aws s3api get-bucket-policy --bucket sys-lgtm-s3
```

### 1.2 네트워크 리소스 확인

**VPC, Subnet, Security Group 확인:**
```bash
# VPC 확인
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=main-vpc"

# Private Subnet 확인 (최소 2개 AZ)
aws ec2 describe-subnets --filters "Name=tag:Name,Values=private-*"

# Security Group 생성
aws ec2 create-security-group \
  --group-name lgtm-ecs-sg \
  --description "Security group for LGTM ECS tasks" \
  --vpc-id vpc-xxx
```

### 체크리스트
- [ ] ECR 리포지토리 6개 생성 완료
- [ ] IAM Role 2개 생성 완료
- [ ] VPC, Subnet 확인 완료
- [ ] Security Group 생성 완료
- [ ] S3 버킷 권한 확인 완료

---

## Phase 2: Dockerfile 작성 (Day 2-3)

### 2.1 기존 설정 파일 분석

**현재 구성:**
```
LGTM_PRD/
├── mimir/
│   ├── mimir_docker-compose.yaml
│   └── config/mimir-config.yaml
├── loki/
│   ├── loki_docker-compose.yaml
│   └── config/loki-config.yaml
├── tempo/
│   ├── tempo-docker-compose.yaml
│   └── config/tempo-config.yaml
...
```

### 2.2 Dockerfile 작성

**각 컴포넌트별 Dockerfile 작성:**

1. **Mimir Dockerfile**
2. **Loki Dockerfile**
3. **Tempo Dockerfile**
4. **Pyroscope Dockerfile**
5. **Grafana Dockerfile**
6. **Alloy Dockerfile**

### 2.3 로컬 테스트

```bash
# Mimir 예시
cd dockerfiles/mimir
docker build -t lgtm-mimir:test .
docker run -it --rm lgtm-mimir:test /usr/bin/mimir --version
```

### 체크리스트
- [ ] Mimir Dockerfile 작성 및 테스트
- [ ] Loki Dockerfile 작성 및 테스트
- [ ] Tempo Dockerfile 작성 및 테스트
- [ ] Pyroscope Dockerfile 작성 및 테스트
- [ ] Grafana Dockerfile 작성 및 테스트
- [ ] Alloy Dockerfile 작성 및 테스트

---

## Phase 3: Task Definition 작성 (Day 4-5)

### 3.1 Task Definition JSON 작성

**컴포넌트별 Task Definition:**

1. **mimir.json** (2 vCPU, 4GB, 3 tasks)
2. **loki.json** (1 vCPU, 2GB, 2 tasks)
3. **tempo.json** (1 vCPU, 2GB, 1 task)
4. **pyroscope.json** (1 vCPU, 2GB, 1 task)
5. **grafana.json** (0.5 vCPU, 1GB, 1 task)
6. **alloy-collector.json** (0.5 vCPU, 1GB, 1 task)

### 3.2 공통 설정

**모든 Task Definition에 포함:**
- `networkMode: "awsvpc"`
- `requiresCompatibilities: ["FARGATE"]`
- `stopTimeout: 120`
- `logConfiguration` (CloudWatch Logs)

### 3.3 환경변수 및 Secrets

**Secrets Manager 설정:**
```bash
aws secretsmanager create-secret \
  --name lgtm/s3-credentials \
  --secret-string '{"AWS_ACCESS_KEY_ID":"xxx","AWS_SECRET_ACCESS_KEY":"xxx"}'
```

### 체크리스트
- [ ] Mimir Task Definition 작성
- [ ] Loki Task Definition 작성
- [ ] Tempo Task Definition 작성
- [ ] Pyroscope Task Definition 작성
- [ ] Grafana Task Definition 작성
- [ ] Alloy Task Definition 작성
- [ ] Secrets Manager 설정 완료

---

## Phase 4: 인프라 구성 (Day 6-8)

### 4.1 ECS Cluster 생성

```bash
aws ecs create-cluster \
  --cluster-name lgtm-cluster \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy \
    capacityProvider=FARGATE,weight=1 \
    capacityProvider=FARGATE_SPOT,weight=4 \
  --settings name=containerInsights,value=enabled
```

### 4.2 AWS CloudMap (Service Discovery) 설정

**Private DNS Namespace 생성:**
```bash
aws servicediscovery create-private-dns-namespace \
  --name lgtm.local \
  --vpc vpc-xxx \
  --description "LGTM Stack Service Discovery"
```

**Service 등록:**
```bash
# Mimir
aws servicediscovery create-service \
  --name mimir \
  --namespace-id ns-xxx \
  --dns-config 'NamespaceId=ns-xxx,DnsRecords=[{Type=A,TTL=10}]'

# Loki, Tempo, Pyroscope, Grafana도 동일하게 생성
```

### 4.3 Application Load Balancer 설정

**ALB 생성:**
```bash
aws elbv2 create-load-balancer \
  --name lgtm-alb \
  --subnets subnet-xxx subnet-yyy \
  --security-groups sg-xxx \
  --scheme internet-facing \
  --type application
```

**Target Group 생성:**
```bash
# Grafana TG
aws elbv2 create-target-group \
  --name lgtm-grafana-tg \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-xxx \
  --target-type ip \
  --health-check-path /api/health

# Mimir, Loki, Tempo도 각각 생성
```

**Listener Rule 설정:**
```bash
# HTTPS Listener (443)
aws elbv2 create-listener \
  --load-balancer-arn <alb-arn> \
  --protocol HTTPS \
  --port 443 \
  --certificates CertificateArn=<acm-arn> \
  --default-actions Type=forward,TargetGroupArn=<grafana-tg-arn>

# Path-based routing
aws elbv2 create-rule \
  --listener-arn <listener-arn> \
  --conditions Field=host-header,Values=grafana.example.com \
  --priority 1 \
  --actions Type=forward,TargetGroupArn=<grafana-tg-arn>
```

### 체크리스트
- [ ] ECS Cluster 생성
- [ ] CloudMap Namespace 생성
- [ ] CloudMap Service 6개 생성
- [ ] ALB 생성
- [ ] Target Group 4개 생성
- [ ] Listener Rule 설정

---

## Phase 5: 이미지 빌드 & 배포 테스트 (Day 9-10)

### 5.1 Docker 이미지 빌드 & ECR 푸시

```bash
#!/bin/bash
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="ap-northeast-2"
ECR_URI="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

# ECR 로그인
aws ecr get-login-password --region $REGION | \
  docker login --username AWS --password-stdin $ECR_URI

# 각 컴포넌트 빌드 & 푸시
cd dockerfiles/mimir
docker build -t lgtm-mimir:latest .
docker tag lgtm-mimir:latest $ECR_URI/lgtm-mimir:latest
docker push $ECR_URI/lgtm-mimir:latest

# Loki, Tempo, Pyroscope, Grafana, Alloy도 동일하게 진행
```

### 5.2 Task Definition 등록

```bash
aws ecs register-task-definition \
  --cli-input-json file://task-definitions/mimir.json

# 나머지도 동일하게 등록
```

### 5.3 ECS Service 생성

```bash
# Mimir Service (3 tasks)
aws ecs create-service \
  --cluster lgtm-cluster \
  --service-name mimir \
  --task-definition lgtm-mimir:1 \
  --desired-count 3 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[subnet-xxx,subnet-yyy],
    securityGroups=[sg-xxx],
    assignPublicIp=DISABLED
  }" \
  --service-registries "registryArn=arn:aws:servicediscovery:...:service/mimir" \
  --load-balancers "targetGroupArn=<mimir-tg-arn>,containerName=mimir,containerPort=9009"

# Loki, Tempo, Pyroscope, Grafana, Alloy도 동일하게 생성
```

### 5.4 동작 확인

```bash
# Service 상태 확인
aws ecs describe-services \
  --cluster lgtm-cluster \
  --services mimir loki tempo pyroscope grafana alloy

# Task 상태 확인
aws ecs list-tasks --cluster lgtm-cluster --service-name mimir

# CloudWatch Logs 확인
aws logs tail /ecs/lgtm-mimir --follow

# Service Discovery 확인
dig mimir.lgtm.local @<vpc-dns-server>
```

### 체크리스트
- [ ] 모든 이미지 빌드 및 ECR 푸시 완료
- [ ] Task Definition 6개 등록 완료
- [ ] ECS Service 6개 생성 완료
- [ ] Service Discovery 동작 확인
- [ ] ALB Health Check 통과 확인
- [ ] 로그 수집 확인

---

## Phase 6: Jenkins CI/CD 구축 (Day 11-12)

### 6.1 Jenkinsfile 작성

**Pipeline 구조:**
```
1. Checkout Code
2. Build Docker Images
3. Push to ECR
4. Register Task Definition
5. Update ECS Service
6. Wait for Deployment
7. Health Check
```

### 6.2 Jenkins 설정

**필요한 Plugin:**
- AWS Steps Plugin
- Docker Pipeline Plugin
- Amazon ECR Plugin

**Credentials 설정:**
- AWS Access Key (Jenkins Credentials)
- ECR Registry (Jenkins Credentials)

### 6.3 파이프라인 테스트

```bash
# Jenkins Job 생성
# Trigger: GitHub Webhook or Manual
# 테스트 배포 실행
```

### 체크리스트
- [ ] Jenkinsfile 작성 완료
- [ ] Jenkins Plugin 설치
- [ ] Credentials 설정
- [ ] 파이프라인 테스트 성공

---

## Phase 7: 트래픽 전환 (Day 13)

### 7.1 Blue/Green 배포 준비

**현재 상태:**
- EC2: 기존 LGTM 스택 운영 중
- ECS: 신규 LGTM 스택 배포 완료

### 7.2 DNS 전환

**Route53 또는 ALB DNS 변경:**
```bash
# 기존: ec2-instance.example.com
# 신규: lgtm-alb-xxx.ap-northeast-2.elb.amazonaws.com

# Grafana DNS
grafana.example.com → lgtm-alb-xxx (ALB)

# 또는 ALB Listener Rule로 Path-based routing
```

### 7.3 점진적 전환

**가중치 기반 라우팅 (선택):**
```
10% → ECS Fargate
90% → EC2 (기존)

↓ (1시간 모니터링)

50% → ECS Fargate
50% → EC2

↓ (1시간 모니터링)

100% → ECS Fargate
```

### 7.4 모니터링

**확인 사항:**
- CloudWatch Container Insights 메트릭
- Grafana 대시보드 정상 로딩
- 메트릭/로그/트레이스 수집 정상
- S3 저장 확인

### 체크리스트
- [ ] DNS 전환 완료
- [ ] Grafana 접속 확인
- [ ] 데이터 수집 정상 확인
- [ ] S3 저장 확인
- [ ] 에러 로그 없음 확인

---

## Phase 8: 정리 및 문서화 (Day 14)

### 8.1 기존 EC2 리소스 정리

**백업 후 종료:**
```bash
# EC2 AMI 생성 (롤백용)
aws ec2 create-image \
  --instance-id i-xxx \
  --name "lgtm-ec2-backup-20251210"

# EC2 중지 (1주일 후 삭제)
aws ec2 stop-instances --instance-ids i-xxx
```

### 8.2 운영 문서 업데이트

- [ ] 아키텍처 다이어그램 업데이트
- [ ] 운영 가이드 작성
- [ ] 트러블슈팅 가이드 작성
- [ ] 백업/복구 절차 문서화

### 8.3 팀 교육

- [ ] ECS Fargate 개념 교육
- [ ] Jenkins CI/CD 사용법 교육
- [ ] 모니터링 방법 교육
- [ ] 장애 대응 절차 교육

---

## 롤백 계획

### 롤백 시나리오

**Case 1: ECS 배포 실패**
→ 기존 EC2는 그대로 유지 (중단 없음)

**Case 2: 배포 성공했으나 데이터 수집 문제**
→ DNS를 EC2로 다시 전환
→ ECS Service Scale Down

**Case 3: 성능 문제**
→ Task 수 증가 또는 리소스 증가
→ 해결 안 되면 EC2로 롤백

### 롤백 절차

```bash
# 1. DNS 롤백
# grafana.example.com → ec2-instance.example.com

# 2. EC2 재시작
aws ec2 start-instances --instance-ids i-xxx

# 3. Docker Compose 재시작
ssh ec2-user@<ec2-ip>
cd /path/to/lgtm
docker-compose up -d

# 4. ECS Service 정지
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --desired-count 0
```

---

## 리스크 관리

| 리스크 | 영향도 | 발생 확률 | 대응 방안 |
|--------|--------|-----------|----------|
| Fargate 리소스 부족 | 높음 | 낮음 | 리전 변경 또는 EC2 Launch Type |
| 데이터 손실 | 높음 | 낮음 | Graceful Shutdown (120초) |
| 성능 저하 | 중간 | 중간 | Task 수 증가, 리소스 증가 |
| 비용 초과 | 낮음 | 중간 | Fargate Spot 활용, Task 수 조정 |
| 네트워크 문제 | 중간 | 낮음 | Multi-AZ 배포 |

---

## 성공 기준

### 기술적 지표

- [ ] 모든 ECS Service가 Healthy 상태
- [ ] Grafana 대시보드 정상 로딩 (응답 시간 < 2초)
- [ ] 메트릭 수집률 99% 이상
- [ ] 로그 수집 지연 < 10초
- [ ] S3 저장 확인

### 운영 지표

- [ ] 장애 발생 0건
- [ ] 데이터 손실 0건
- [ ] Jenkins CI/CD 파이프라인 성공률 100%
- [ ] 배포 시간 < 10분

---

**Last Updated:** 2025-12-10
