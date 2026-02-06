# MyCard Server — 프로젝트 컨텍스트

## ⚠️ Claude 행동 규칙

- **Claude는 이 프로젝트의 파일을 직접 생성/수정하지 않는다**
- 오직 **단계별 가이드와 설명만 제공**한다
- 사용자가 직접 명령어를 실행하고 코드를 작성한다
- 핵심 설계 결정은 사용자에게 선택권을 제공한다

## 프로젝트 개요

- **목적**: 카드 결제 완료 처리에 따른 결제 내역 기록 및 조회 REST API 서버
- **프로젝트명**: mycard-server

## 기술 스택 (확정)

| 항목         | 선택                     | 비고                           |
| ------------ | ------------------------ | ------------------------------ |
| 런타임       | **Bun**                  | v1.3.6 설치 확인됨             |
| 프레임워크   | **Elysia**               | Bun 네이티브 프레임워크        |
| 언어         | **TypeScript**           | Bun이 네이티브 지원            |
| ORM          | **Drizzle ORM**          | Bun과 궁합 좋은 TypeScript ORM |
| 데이터베이스 | **PostgreSQL** (AWS RDS) |                                |
| 인프라 관리  | **Terraform**            | IaC (Infrastructure as Code)   |
| 컨테이너     | **Docker**               | v27.4.0 설치 확인됨            |
| 배포 대상    | **AWS ECS Fargate**      | 서버리스 컨테이너              |

## AWS 아키텍처 (목표)

```
인터넷
  ↓
[ALB - Ap# MyCard Server — 프로젝트 컨텍스트

  ## ⚠️ Claude 행동 규칙
  - **Claude는 이 프로젝트의 파일을 직접 생성/수정하지 않는다**
  - 오직 **단계별 가이드와 설명만 제공**한다
  - 사용자가 직접 명령어를 실행하고 코드를 작성한다
  - 핵심 설계 결정은 사용자에게 선택권을 제공한다

  ## 프로젝트 개요
  - **목적**: 카드 결제 완료 처리에 따른 결제 내역 기록 및 조회 REST API 서버
  - **프로젝트명**: mycard-server

  ## 기술 스택 (확정)
  | 항목 | 선택 | 비고 |
  |------|------|------|
  | 언어 | **Go** | v1.25 |
  | 프레임워크 | **Gin** | v1.11.0 |
  | ORM | **GORM** | (Step 3에서 설치 예정) |
  | 데이터베이스 | **PostgreSQL** (AWS RDS) | |
  | 인프라 관리 | **Terraform** | IaC (Infrastructure as Code) |
  | 컨테이너 | **Docker** | v27.4.0 설치 확인됨 |
  | 배포 대상 | **AWS ECS Fargate** | 서버리스 컨테이너 |

  ## AWS 아키텍처 (목표)
  인터넷
    ↓
  [ALB - Application Load Balancer]
    ↓
  [ECS Fargate - Go/Gin 서버]      ← Public Subnet
    ↓
  [RDS PostgreSQL]                  ← Private Subnet

  ## Terraform 파일 구조 (목표)
  terraform/
  ├── main.tf          # 프로바이더 설정
  ├── variables.tf     # 변수 정의
  ├── outputs.tf       # 출력값 (ALB URL 등)
  ├── vpc.tf           # VPC, 서브넷, 게이트웨이
  ├── security.tf      # 보안 그룹
  ├── rds.tf           # PostgreSQL RDS
  ├── ecr.tf           # 컨테이너 레지스트리
  ├── ecs.tf           # ECS 클러스터, 태스크, 서비스
  └── alb.tf           # 로드 밸런서

  ## 가이드 스타일
  - 모든 명령어에 **"이 명령어가 무엇을 하는지"** 설명을 포함한다
  - 명령어의 각 옵션/플래그도 간단히 설명한다
  - 처음 등장하는 개념은 비유나 비교로 쉽게 풀어준다

  ## 사용자 배경
  - **Node.js/TypeScript 경험자**, Go는 처음
  - Go 문법, 키워드, 관례 등 **기초부터 설명 필요**
  - Node.js와 비교하면 이해가 빠름

  ## 학습 진행 상황

  ### Step 1: 개발 환경 준비 — ✅ 완료
  - [x] Go 설치 확인 (v1.25)
  - [x] Git 설치 확인 (v2.47.0)
  - [x] Docker 설치 확인 (v27.4.0)
  - [x] AWS CLI 설치 및 자격 증명 설정
  - [x] Terraform 설치
  - [x] Git 초기화

  ### Step 2: Go + Gin 프로젝트 초기화 — ✅ 완료
  - [x] Go 모듈 초기화 (`go mod init`)
  - [x] Gin 프레임워크 설치
  - [x] cmd/server/main.go 작성
  - [x] /health 엔드포인트 동작 확인

  ### Step 3: 데이터베이스 스키마 설계 — 🔄 진행 중
  ### Step 4: API 구현 (로컬) — ⏳ 대기
  ### Step 5: Docker 컨테이너화 — ⏳ 대기
  ### Step 6: Terraform으로 AWS 인프라 구성 — ⏳ 대기
  ### Step 7: 배포 및 검증 — ⏳ 대기
plication Load Balancer]
  ↓
[ECS Fargate - Bun/Elysia 서버]  ← Public Subnet
  ↓
[RDS PostgreSQL]                  ← Private Subnet
```

## Terraform 파일 구조 (목표)

```
terraform/
├── main.tf          # 프로바이더 설정
├── variables.tf     # 변수 정의
├── outputs.tf       # 출력값 (ALB URL 등)
├── vpc.tf           # VPC, 서브넷, 게이트웨이
├── security.tf      # 보안 그룹
├── rds.tf           # PostgreSQL RDS
├── ecr.tf           # 컨테이너 레지스트리
├── ecs.tf           # ECS 클러스터, 태스크, 서비스
└── alb.tf           # 로드 밸런서
```

## 학습 진행 상황

### Step 1: 개발 환경 준비 — 🔄 진행 중

- [x] Bun 설치 확인 (v1.3.6)
- [x] Git 설치 확인 (v2.47.0)
- [x] Docker 설치 확인 (v27.4.0)
- [ ] AWS CLI 설치 (`brew install awscli`)
- [ ] AWS 자격 증명 설정 (`aws configure`)
- [ ] Terraform 설치 (`brew tap hashicorp/tap && brew install hashicorp/tap/terraform`)
- [ ] Git 초기화 (`git init`)

### Step 2: Bun + Elysia 프로젝트 초기화 — ⏳ 대기

### Step 3: 데이터베이스 스키마 설계 — ⏳ 대기

### Step 4: API 구현 (로컬) — ⏳ 대기

### Step 5: Docker 컨테이너화 — ⏳ 대기

### Step 6: Terraform으로 AWS 인프라 구성 — ⏳ 대기

### Step 7: 배포 및 검증 — ⏳ 대기
