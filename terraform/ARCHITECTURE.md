# Terraform 인프라 구조 설명서

## 전체 아키텍처

```
인터넷
  ↓
[ALB - Application Load Balancer]     ← 고정 URL 제공, 요청 분배
  ↓
[ECS Fargate - Go/Gin 서버]           ← Public Subnet (인터넷 접근 가능)
  ↓
[RDS PostgreSQL]                      ← Private Subnet (인터넷 접근 차단)
```

## VPC 네트워크 구조

```
┌─────────────── VPC (10.0.0.0/16) ───────────────────┐
│                                                       │
│   ┌─── AZ: ap-northeast-2a ──┐  ┌─── AZ: 2c ──────┐ │
│   │                          │  │                   │ │
│   │  Public Subnet A         │  │  Public Subnet C  │ │
│   │  10.0.1.0/24             │  │  10.0.2.0/24      │ │
│   │  (ALB, ECS 서버)         │  │  (ALB, ECS 서버)  │ │
│   │                          │  │                   │ │
│   │  Private Subnet A        │  │  Private Subnet C │ │
│   │  10.0.10.0/24            │  │  10.0.11.0/24     │ │
│   │  (RDS DB)                │  │  (RDS DB)         │ │
│   │                          │  │                   │ │
│   └──────────────────────────┘  └───────────────────┘ │
│                                                       │
│              ┌──────────────────┐                     │
│              │ Internet Gateway │ ← 인터넷 출입구     │
│              └──────────────────┘                     │
└───────────────────────────────────────────────────────┘
                       ↕
                    인터넷
```

## 핵심 개념 설명

### VPC (Virtual Private Cloud)

AWS 안에서 나만의 가상 네트워크를 만드는 것.

- **비유**: 아파트 단지 전체 (울타리 안)
- `cidr_block = "10.0.0.0/16"` → 이 VPC에서 사용할 IP 범위 (65,536개)

### Subnet (서브넷)

VPC를 구역별로 나눈 것.

- **비유**: 아파트 단지 안의 각 동
- Public Subnet: 인터넷 접근 가능 (ALB, ECS용)
- Private Subnet: 인터넷 접근 차단 (RDS용)

### Availability Zone (가용 영역)

리전 안의 물리적으로 분리된 데이터센터.

```
서울 리전 (ap-northeast-2)
├── AZ a ── 물리적 데이터센터 건물 1
├── AZ b ── 물리적 데이터센터 건물 2
├── AZ c ── 물리적 데이터센터 건물 3
└── AZ d ── 물리적 데이터센터 건물 4
```

- ALB, RDS는 최소 2개 AZ에 걸쳐야 함 (AWS 규칙)
- 하나가 장애 나도 다른 곳에서 서비스 유지 (고가용성)

### Internet Gateway

VPC와 인터넷을 연결하는 출입구.

- **비유**: 아파트 단지의 정문
- VPC는 기본적으로 인터넷과 단절되어 있음
- Internet Gateway를 붙여야 인터넷 접근 가능

### Route Table (라우팅 테이블)

트래픽의 목적지별 경로를 안내하는 규칙표.

- **비유**: 네비게이션의 방향 표지판

```
| 목적지        | 대상              | 의미                          |
|--------------|-------------------|-------------------------------|
| 10.0.0.0/16  | local             | VPC 내부끼리 직접 통신 (자동)   |
| 0.0.0.0/0    | Internet Gateway  | 그 외 전부 → 인터넷 (직접 추가) |
```

- Public Subnet: 위 Route Table 연결 → 인터넷 접근 가능
- Private Subnet: 연결 안 함 → 인터넷 접근 차단

### Security Group (보안 그룹)

리소스별 방화벽 규칙. 어떤 트래픽을 허용/차단할지 정의.

- **비유**: 각 동의 출입 카드
- ALB: 80/443 포트만 외부에서 접근 허용
- ECS: ALB에서 오는 8080 포트만 허용
- RDS: ECS에서 오는 5432 포트만 허용

### ALB (Application Load Balancer)

인터넷 요청을 서버에 분배하는 중간 다리.

- 고정 URL 제공 (ECS 컨테이너 IP는 배포마다 바뀜)
- 헬스 체크 (/health에 주기적으로 요청)
- 서버 여러 대일 때 요청을 골고루 분배

### ECS Fargate

Docker 컨테이너를 서버리스로 실행하는 서비스.

- 서버(EC2)를 직접 관리하지 않아도 됨
- Docker 이미지만 제공하면 AWS가 알아서 실행
- ECR(컨테이너 레지스트리)에 이미지를 올리고, ECS가 가져다 실행

### RDS (Relational Database Service)

AWS에서 관리하는 데이터베이스 서비스.

- Private Subnet에 배치 → 인터넷에서 직접 접근 불가
- ECS 서버만 접근 가능 (Security Group으로 제어)
- 자동 백업, 패치 등 AWS가 관리

## CIDR 표기법 참고

```
10.0.0.0/16  → /16 = 앞 16비트 고정 → 10.0.은 고정, 나머지 자유 (65,536개 IP)
10.0.1.0/24  → /24 = 앞 24비트 고정 → 10.0.1.은 고정, 마지막만 자유 (256개 IP)
```

숫자가 작을수록 범위가 넓고, 클수록 좁음.

## Terraform 파일 구조

```
terraform/
├── main.tf          # 프로바이더 설정 (AWS 연결)
├── variables.tf     # 변수 정의 (리전, 프로젝트명, DB 비밀번호 등)
├── outputs.tf       # 출력값 (terraform apply 후 ALB URL 표시)
├── vpc.tf           # VPC, 서브넷, Internet Gateway, Route Table
├── security.tf      # 보안 그룹 (ALB, ECS, RDS별 방화벽)
├── rds.tf           # PostgreSQL RDS 인스턴스
├── ecr.tf           # ECR (Docker 이미지 저장소)
├── ecs.tf           # ECS 클러스터, 태스크 정의, 서비스
└── alb.tf           # ALB + Target Group + Listener
```

## 보안 구조 (트래픽 흐름)

```
인터넷
  ↓ (80/443 포트만 허용)
[ALB Security Group]
  ↓ (8080 포트, ALB에서 온 것만 허용)
[ECS Security Group]
  ↓ (5432 포트, ECS에서 온 것만 허용)
[RDS Security Group]
```

각 단계마다 Security Group이 필터링하여, 허용된 트래픽만 통과.
