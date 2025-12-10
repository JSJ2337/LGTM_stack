# LGTM Stack ECS Fargate Troubleshooting Guide

## 일반적인 문제 및 해결 방법

---

## 1. ECS Task 시작 실패

### 문제: Task가 PENDING 상태에서 멈춤

**증상:**
```
Task 상태: PENDING
Desired: 3
Running: 0
```

**원인 및 해결:**

#### 1.1 Subnet에 사용 가능한 IP 없음
```bash
# 확인
aws ec2 describe-subnets --subnet-ids subnet-xxx

# 해결: 다른 Subnet 사용 또는 IP 확보
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-yyy]}"
```

#### 1.2 Security Group 규칙 문제
```bash
# 확인
aws ec2 describe-security-groups --group-ids sg-xxx

# 해결: Egress 규칙에 443 포트 허용 (ECR 이미지 풀링용)
aws ec2 authorize-security-group-egress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0
```

#### 1.3 ECR 이미지 풀링 실패
```bash
# 증상: CloudWatch Logs
CannotPullContainerError: pull image manifest has been retried

# 원인: IAM Role에 ECR 권한 없음

# 해결: Task Execution Role에 권한 추가
aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

---

## 2. Task가 즉시 종료됨

### 문제: Task가 시작했다가 바로 STOPPED

**CloudWatch Logs 확인:**
```bash
aws logs tail /ecs/lgtm-mimir --follow
```

### 2.1 설정 파일 오류

**증상:**
```
Error: failed to parse config: yaml: unmarshal errors
```

**해결:**
1. Task Definition의 환경변수 확인
2. Secrets Manager 값 확인
3. 로컬에서 설정 파일 테스트

```bash
# 로컬 테스트
docker run -it --rm \
  -v $(pwd)/config:/etc/mimir \
  grafana/mimir:latest \
  -config.file=/etc/mimir/mimir.yaml \
  -target=all
```

### 2.2 S3 접근 권한 문제

**증상:**
```
Error: failed to create bucket client: Access Denied
```

**해결:**
```bash
# Task Role에 S3 권한 추가
aws iam put-role-policy \
  --role-name lgtmTaskRole \
  --policy-name S3FullAccess \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::sys-lgtm-s3", "arn:aws:s3:::sys-lgtm-s3/*"]
    }]
  }'
```

### 2.3 메모리 부족 (OOMKilled)

**증상:**
```
Essential container in task exited
Reason: OutOfMemoryError
```

**해결:**
```bash
# Task Definition에서 메모리 증가
# 현재: 2048 MB → 변경: 4096 MB

aws ecs register-task-definition \
  --cli-input-json file://task-definitions/mimir-updated.json
```

---

## 3. Service Discovery 문제

### 문제: 컨테이너 간 통신 실패

**증상:**
```
# Mimir 로그
failed to join memberlist cluster: no peers to join
```

**확인:**
```bash
# CloudMap Service 확인
aws servicediscovery list-services \
  --filters Name=NAMESPACE_ID,Values=ns-xxx

# DNS 확인 (ECS Task 내에서)
dig mimir.lgtm.local
```

**해결:**

#### 3.1 interface_names 설정 누락

**Mimir/Loki/Tempo 설정 파일에 추가:**
```yaml
memberlist:
  interface_names: ["eth1"]  # Fargate 필수!
  join_members:
    - mimir.lgtm.local:7946
```

#### 3.2 Security Group 7946 포트 미허용

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 7946 \
  --source-group sg-xxx
```

---

## 4. Graceful Shutdown 실패

### 문제: Task 종료 시 데이터 손실

**증상:**
- Ingester 종료 시 메모리 청크가 S3로 플러시되지 않음
- 데이터 누락

**해결:**

#### 4.1 stopTimeout 증가

```json
{
  "containerDefinitions": [{
    "stopTimeout": 120  // 120초로 설정
  }]
}
```

#### 4.2 Tini 사용

**Dockerfile:**
```dockerfile
FROM grafana/mimir:latest

# Tini 설치
RUN apk add --no-cache tini

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/bin/mimir", "-config.file=/etc/mimir/config.yaml"]
```

#### 4.3 Flush Endpoint 사용

```bash
# Task 종료 전 수동 플러시
curl -X POST http://mimir.lgtm.local:9009/ingester/flush
```

---

## 5. Load Balancer Health Check 실패

### 문제: Target이 Unhealthy 상태

**확인:**
```bash
aws elbv2 describe-target-health \
  --target-group-arn <tg-arn>
```

**증상:**
```
State: unhealthy
Reason: Target.ResponseCodeMismatch
```

**해결:**

#### 5.1 Health Check Path 수정

```bash
# Grafana 예시
aws elbv2 modify-target-group \
  --target-group-arn <grafana-tg-arn> \
  --health-check-path /api/health \
  --health-check-interval-seconds 30 \
  --health-check-timeout-seconds 5 \
  --healthy-threshold-count 2 \
  --unhealthy-threshold-count 3
```

#### 5.2 Readiness Probe 추가

**Loki 예시:**
```yaml
server:
  http_listen_port: 3100

# /ready endpoint가 활성화됨
```

#### 5.3 Security Group 규칙 확인

```bash
# ALB에서 Target으로 Health Check 허용
aws ec2 authorize-security-group-ingress \
  --group-id <ecs-sg> \
  --protocol tcp \
  --port 3100 \
  --source-group <alb-sg>
```

---

## 6. 성능 문제

### 6.1 높은 CPU 사용률

**증상:**
- CPU 사용률 > 80%
- 쿼리 응답 느림

**해결:**

```bash
# Task 수 증가
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --desired-count 5

# 또는 vCPU 증가
# Task Definition에서 cpu: "2048" → "4096"
```

### 6.2 높은 메모리 사용률

**증상:**
- Memory 사용률 > 90%
- OOMKilled 발생

**해결:**

```bash
# 메모리 증가
# Task Definition에서 memory: "4096" → "8192"

# Ingester 설정 튜닝 (Mimir)
ingester:
  max_chunk_age: 2h  # 청크 플러시 주기 단축
```

### 6.3 쿼리 느림

**해결:**

```bash
# Querier 수 증가
# desired_count 증가

# Memcached 추가 (Loki)
# Sidecar 컨테이너로 Memcached 추가
```

---

## 7. 데이터 수집 문제

### 7.1 메트릭이 Mimir에 저장되지 않음

**확인:**
```bash
# Alloy Collector 로그 확인
aws logs tail /ecs/lgtm-alloy --follow

# Mimir Ingester 로그 확인
aws logs tail /ecs/lgtm-mimir --follow --filter-pattern "error"
```

**해결:**

#### Tenant Header 확인
```yaml
# Alloy Collector 설정
prometheus.remote_write "mimir" {
  endpoint {
    url = "http://mimir.lgtm.local:9009/api/v1/push"
    headers = {
      "X-Scope-OrgID" = "aws-rag-ec2"  # Tenant ID 확인
    }
  }
}
```

### 7.2 로그가 Loki에 저장되지 않음

**확인:**
```bash
# Loki Distributor 로그
aws logs tail /ecs/lgtm-loki --follow --filter-pattern "push"
```

**해결:**

```yaml
# Alloy Collector 설정
loki.write "default" {
  endpoint {
    url = "http://loki.lgtm.local:3100/loki/api/v1/push"
    tenant_id = "aws-rag-ec2"  # 확인
  }
}
```

### 7.3 트레이스가 Tempo에 저장되지 않음

**확인:**
```bash
# Tempo Distributor 로그
aws logs tail /ecs/lgtm-tempo --follow
```

**해결:**

```yaml
# 애플리케이션 OpenTelemetry 설정 확인
OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo.lgtm.local:4317
```

---

## 8. S3 저장 문제

### 8.1 S3에 데이터가 저장되지 않음

**확인:**
```bash
# S3 버킷 확인
aws s3 ls s3://sys-lgtm-s3/blocks/ --recursive

# IAM 권한 확인
aws iam get-role-policy --role-name lgtmTaskRole --policy-name S3Access
```

**해결:**

```bash
# Task Role에 S3 권한 추가
aws iam put-role-policy \
  --role-name lgtmTaskRole \
  --policy-name S3FullAccess \
  --policy-document file://s3-policy.json
```

### 8.2 S3 접근 속도 느림

**해결:**

```yaml
# Mimir 설정: S3 전송 최적화
blocks_storage:
  s3:
    bucket_name: sys-lgtm-s3
    endpoint: s3.ap-northeast-2.amazonaws.com
    # 멀티파트 업로드 활성화
    send_content_md5: false
```

---

## 9. Jenkins CI/CD 문제

### 9.1 ECR 푸시 실패

**증상:**
```
denied: Your authorization token has expired
```

**해결:**
```groovy
// Jenkinsfile
stage('ECR Login') {
  steps {
    sh '''
      aws ecr get-login-password --region ap-northeast-2 | \
        docker login --username AWS --password-stdin ${ECR_URI}
    '''
  }
}
```

### 9.2 ECS 배포 타임아웃

**증상:**
```
Deployment circuit breaker: deployment failed
```

**해결:**

```bash
# Health Check 설정 완화
aws elbv2 modify-target-group \
  --target-group-arn <tg-arn> \
  --health-check-interval-seconds 60 \
  --healthy-threshold-count 2

# 배포 타임아웃 증가
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --deployment-configuration "maximumPercent=200,minimumHealthyPercent=50,deploymentCircuitBreaker={enable=true,rollback=false}"
```

---

## 10. 비용 초과 문제

### 10.1 Fargate 비용 증가

**확인:**
```bash
# Cost Explorer에서 Fargate 비용 확인
aws ce get-cost-and-usage \
  --time-period Start=2025-12-01,End=2025-12-10 \
  --granularity DAILY \
  --metrics BlendedCost \
  --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Elastic Container Service"]}}'
```

**해결:**

#### Fargate Spot 사용
```bash
# Capacity Provider Strategy 변경
aws ecs update-service \
  --cluster lgtm-cluster \
  --service querier \
  --capacity-provider-strategy \
    capacityProvider=FARGATE_SPOT,weight=4 \
    capacityProvider=FARGATE,weight=1
```

#### Task 수 최적화
```bash
# 불필요한 Task 제거
aws ecs update-service \
  --cluster lgtm-cluster \
  --service pyroscope \
  --desired-count 0  # 사용하지 않으면 0으로
```

---

## 일반적인 디버깅 명령어

### ECS 상태 확인
```bash
# Service 상태
aws ecs describe-services \
  --cluster lgtm-cluster \
  --services mimir

# Task 목록
aws ecs list-tasks \
  --cluster lgtm-cluster \
  --service-name mimir

# Task 상세
aws ecs describe-tasks \
  --cluster lgtm-cluster \
  --tasks <task-arn>
```

### CloudWatch Logs 확인
```bash
# 실시간 로그
aws logs tail /ecs/lgtm-mimir --follow

# 에러 필터
aws logs tail /ecs/lgtm-mimir --follow --filter-pattern "ERROR"

# 최근 10분
aws logs tail /ecs/lgtm-mimir --since 10m
```

### Service Discovery 확인
```bash
# CloudMap Service 인스턴스
aws servicediscovery list-instances \
  --service-id srv-xxx

# DNS 확인 (ECS Task 내부)
aws ecs execute-command \
  --cluster lgtm-cluster \
  --task <task-id> \
  --container mimir \
  --command "dig mimir.lgtm.local" \
  --interactive
```

### ALB 상태 확인
```bash
# Target Health
aws elbv2 describe-target-health \
  --target-group-arn <tg-arn>

# ALB Access Logs 활성화
aws elbv2 modify-load-balancer-attributes \
  --load-balancer-arn <alb-arn> \
  --attributes Key=access_logs.s3.enabled,Value=true \
               Key=access_logs.s3.bucket,Value=my-alb-logs
```

---

## 긴급 대응 절차

### 장애 발생 시

**1단계: 영향 범위 확인**
```bash
# 모든 Service 상태 확인
aws ecs describe-services \
  --cluster lgtm-cluster \
  --services mimir loki tempo grafana
```

**2단계: 롤백**
```bash
# 이전 Task Definition으로 롤백
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --task-definition lgtm-mimir:1  # 이전 버전
```

**3단계: Scale Out**
```bash
# Task 수 긴급 증가
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --desired-count 10
```

**4단계: EC2로 완전 롤백 (최후의 수단)**
```bash
# EC2 재시작
aws ec2 start-instances --instance-ids i-xxx

# ECS Service 중지
aws ecs update-service \
  --cluster lgtm-cluster \
  --service mimir \
  --desired-count 0
```

---

**Last Updated:** 2025-12-10
