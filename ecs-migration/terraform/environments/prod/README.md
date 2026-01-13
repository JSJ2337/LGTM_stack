# LGTM Stack - Production Environment

Terraform을 사용한 LGTM Stack ECS Fargate 인프라 배포 환경입니다.

## 구조

```text
prod/
├── common.tfvars            # 공통 설정 (모든 모듈에서 사용)
├── 01-vpc/                  # VPC, Subnet, NAT Gateway
├── 10-ecr/                  # ECR 리포지토리
├── 20-iam/                  # IAM Roles & Policies
├── 30-security-groups/      # Security Groups
├── 40-cloudmap/             # Service Discovery (CloudMap)
├── 50-alb/                  # Application Load Balancer
└── 60-ecs/                  # ECS Cluster & Services
```

## 배포 순서

모듈은 **반드시 순서대로** 배포해야 합니다:

| 순서 | 폴더 | 설명 | 종속성 |
|------|------|------|--------|
| 1 | 01-vpc | VPC 네트워크 | 없음 |
| 2 | 10-ecr | ECR 리포지토리 | 없음 (병렬 가능) |
| 3 | 20-iam | IAM 역할 | 없음 (병렬 가능) |
| 4 | 30-security-groups | 보안 그룹 | 01-vpc |
| 5 | 40-cloudmap | 서비스 디스커버리 | 01-vpc |
| 6 | 50-alb | 로드 밸런서 | 01-vpc, 30-security-groups |
| 7 | 60-ecs | ECS 서비스 | 모든 이전 모듈 |

## 사용법

### 1. 공통 설정 확인

`common.tfvars` 파일에서 공통 설정을 확인합니다:

```hcl
aws_region   = "ap-northeast-2"
environment  = "prod"
project_name = "lgtm"
```

### 2. 개별 모듈 배포

각 모듈 폴더로 이동하여 배포합니다:

```bash
# VPC 배포
cd 01-vpc
terraform init
terraform plan -var-file="../common.tfvars" -var-file="terraform.tfvars"
terraform apply -var-file="../common.tfvars" -var-file="terraform.tfvars"

# ECR 배포
cd ../10-ecr
terraform init
terraform plan -var-file="../common.tfvars" -var-file="terraform.tfvars"
terraform apply -var-file="../common.tfvars" -var-file="terraform.tfvars"

# ... 나머지 모듈도 동일하게 진행
```

### 3. 전체 배포 스크립트 (선택)

```bash
#!/bin/bash
MODULES="01-vpc 10-ecr 20-iam 30-security-groups 40-cloudmap 50-alb 60-ecs"

for module in $MODULES; do
  echo "Deploying $module..."
  cd $module
  terraform init
  terraform apply -var-file="../common.tfvars" -var-file="terraform.tfvars" -auto-approve
  cd ..
done
```

## 삭제 순서

삭제는 **역순**으로 진행합니다:

```bash
MODULES="60-ecs 50-alb 40-cloudmap 30-security-groups 20-iam 10-ecr 01-vpc"

for module in $MODULES; do
  echo "Destroying $module..."
  cd $module
  terraform destroy -var-file="../common.tfvars" -var-file="terraform.tfvars" -auto-approve
  cd ..
done
```

## State 관리

각 모듈은 독립적인 Terraform state 파일을 가집니다:

| 모듈 | State Key |
|------|-----------|
| 01-vpc | `lgtm-ecs/prod/01-vpc/terraform.tfstate` |
| 10-ecr | `lgtm-ecs/prod/10-ecr/terraform.tfstate` |
| 20-iam | `lgtm-ecs/prod/20-iam/terraform.tfstate` |
| 30-security-groups | `lgtm-ecs/prod/30-security-groups/terraform.tfstate` |
| 40-cloudmap | `lgtm-ecs/prod/40-cloudmap/terraform.tfstate` |
| 50-alb | `lgtm-ecs/prod/50-alb/terraform.tfstate` |
| 60-ecs | `lgtm-ecs/prod/60-ecs/terraform.tfstate` |

## 주의사항

1. **순서 준수**: 종속성이 있는 모듈은 반드시 순서대로 배포해야 합니다.
2. **State 버킷**: 배포 전 S3 버킷 `jsj-lgtm-terraform-state`와 DynamoDB 테이블 `jsj-lgtm-terraform-locks`가 생성되어 있어야 합니다.
3. **ECR 이미지**: ECS 서비스 배포 전 ECR에 이미지가 push되어 있어야 합니다.
