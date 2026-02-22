# MyCard Server - 배포 가이드

## 사전 준비

- Docker Desktop 실행 상태
- AWS CLI 자격 증명 설정 완료

## 배포 순서

### 1. AWS 계정 ID 확인

```bash
aws sts get-caller-identity --query Account --output text
```

출력되는 12자리 숫자를 아래 명령어의 `<계정ID>`에 대입합니다.

### 2. ECR 로그인

```bash
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com
```

`Login Succeeded` 메시지가 나오면 성공입니다.

### 3. Docker 이미지 빌드

```bash
docker build --platform linux/amd64 -t mycard-server .
```

- `--platform linux/amd64` — Apple Silicon Mac에서도 ECS Fargate 호환 이미지를 빌드합니다.

### 4. ECR에 태그 및 푸시

```bash
docker tag mycard-server:latest <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/mycard-server:latest

docker push <계정ID>.dkr.ecr.ap-northeast-2.amazonaws.com/mycard-server:latest
```

### 5. ECS 서비스 재배포

```bash
aws ecs update-service --cluster mycard-cluster --service mycard-service --force-new-deployment --region ap-northeast-2
```

### 6. 배포 상태 확인

```bash
aws ecs describe-services --cluster mycard-cluster --services mycard-service --region ap-northeast-2 --query "services[0].deployments"
```

- `runningCount: 1`, `rolloutState: COMPLETED` 이면 배포 완료입니다.
- 반영까지 2~3분 소요됩니다.

### 7. API 동작 검증

```bash
# Health Check
curl http://mycard-alb-1032538317.ap-northeast-2.elb.amazonaws.com/health

# 결제 생성 테스트
curl -X POST http://mycard-alb-1032538317.ap-northeast-2.elb.amazonaws.com/payments \
  -H "Content-Type: application/json" \
  -d '{"card_number":"1234-5678-9012-3456","amount":15000,"merchant_name":"테스트가게","status":"APPROVED"}'

# 결제 목록 조회
curl http://mycard-alb-1032538317.ap-northeast-2.elb.amazonaws.com/payments
```

## 인프라 관리 (비용 절감)

개발 중에는 테스트할 때만 인프라를 생성하고, 끝나면 삭제하여 비용을 0원으로 유지합니다.

### 인프라 삭제 (비용 중단)

```bash
cd terraform
terraform destroy -var="db_password=<DB비밀번호>"
```

- 모든 리소스 목록이 표시되고 `yes` 입력 시 삭제 시작
- 약 5~10분 소요
- RDS 데이터는 삭제됨 (개발 단계에서는 무관)

### 인프라 재생성 (테스트 필요 시)

```bash
cd terraform
terraform apply -var="db_password=<DB비밀번호>"
```

- 약 10~15분 소요
- 완료 후 ALB DNS 주소가 새로 출력됨 (이전과 다를 수 있음)
- 이후 위의 **배포 순서 1~7번**을 다시 실행

## 트러블슈팅

### Docker 데몬 연결 에러

```
Cannot connect to the Docker daemon
```

-> Docker Desktop을 실행하세요. (`Cmd + Space` → Docker 검색)

### ECS 태스크가 계속 실패할 때

```bash
# CloudWatch 로그 확인
aws logs tail /ecs/mycard --region ap-northeast-2 --since 10m
```

### ECR 로그인 만료

ECR 토큰은 **12시간** 유효합니다. 만료되면 2번(ECR 로그인)부터 다시 실행하세요.
