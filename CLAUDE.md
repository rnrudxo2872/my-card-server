# MyCard Server — 프로젝트 컨텍스트

## ⚠️ Claude 행동 규칙

- **Claude는 이 프로젝트의 파일을 직접 생성/수정하지 않는다 (md 파일 제외 - 스펙 업데이트를 위함)**
- 오직 **단계별 가이드와 설명만 제공**한다
- 사용자가 직접 명령어를 실행하고 코드를 작성한다
- 핵심 설계 결정은 사용자에게 선택권을 제공한다

## 프로젝트 개요

- **목적**: 카드 결제 완료 처리에 따른 결제 내역 기록 및 조회 REST API 서버
- **프로젝트명**: mycard-server

## 기술 스택 (확정)

| 항목         | 선택                     | 비고                         |
| ------------ | ------------------------ | ---------------------------- |
| 언어         | **Go**                   | v1.25                        |
| 프레임워크   | **Gin**                  | v1.11.0                      |
| ORM          | **GORM**                 | v1.31.1                      |
| 데이터베이스 | **PostgreSQL** (AWS RDS) |                              |
| 인프라 관리  | **Terraform**            | IaC (Infrastructure as Code) |
| 컨테이너     | **Docker**               | v27.4.0 설치 확인됨          |
| 배포 대상    | **AWS ECS Fargate**      | 서버리스 컨테이너            |

## AWS 아키텍처 (목표)

```
인터넷
  ↓
[ALB - Application Load Balancer]
  ↓
[ECS Fargate - Go/Gin 서버]      ← Public Subnet
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

## 가이드 스타일

- 모든 명령어에 **"이 명령어가 무엇을 하는지"** 설명을 포함한다
- 명령어의 각 옵션/플래그도 간단히 설명한다
- 처음 등장하는 개념은 비유나 비교로 쉽게 풀어준다

## 사용자 배경

- **Node.js/TypeScript 경험자**, Go는 처음
- Go 문법, 키워드, 관례 등 **기초부터 설명 필요**
- Node.js와 비교하면 이해가 빠름
- 코드 예시에는 **각 줄의 역할과 Go 문법 설명**을 포함한다
- 새로운 Go 키워드/문법이 처음 등장할 때 반드시 설명한다 (type, struct, :=, *, 대소문자 규칙 등)

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

### Step 3: 데이터베이스 스키마 설계 — ✅ 완료

- [x] 로컬 PostgreSQL 실행 (Docker Compose)
- [x] GORM 및 PostgreSQL 드라이버 설치
- [x] Payment 모델 설계 (PaymentStatus enum 포함)
- [x] GORM AutoMigrate로 테이블 자동 생성
- [x] Makefile, README.md, .gitignore 추가

### Step 4: API 구현 (로컬) — ✅ 완료

- [x] POST /payments (결제 기록 생성)
- [x] GET /payments (목록 조회 + 필터링 + 페이지네이션)
- [x] GET /payments/:id (단건 조회)
- [x] Status 유효성 검사 (GORM BeforeCreate Hook)

### Step 5: Docker 컨테이너화 — ✅ 완료

- [x] Dockerfile 작성 (멀티스테이지 빌드)
- [x] docker-compose.yml에 서버 + DB 구성
- [x] 환경변수(DATABASE_URL)로 DB 접속 정보 분리
- [x] docker compose up으로 전체 실행 확인

### Step 6: Terraform으로 AWS 인프라 구성 — 🔄 진행 중

### Step 7: 배포 및 검증 — ⏳ 대기
