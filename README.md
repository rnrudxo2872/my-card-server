# MyCard Server

카드 결제 완료 처리에 따른 결제 내역 기록 및 조회 REST API 서버

## 기술 스택

| 항목         | 선택       |
| ------------ | ---------- |
| 언어         | Go         |
| 프레임워크   | Gin        |
| ORM          | GORM       |
| 데이터베이스 | PostgreSQL |
| 컨테이너     | Docker     |

## 사전 준비

- [Go](https://go.dev/dl/) (v1.24+)
- [Docker](https://www.docker.com/products/docker-desktop/)

## 시작하기

### 1. 의존성 설치

```bash
go mod download

2. DB 실행

# macOS/Linux (make 사용)
make db-up

# 직접 실행
docker compose up -d

3. 서버 실행

# macOS/Linux (make 사용)
make run

# 직접 실행
go run cmd/server/main.go

4. 동작 확인

curl http://localhost:8080/health
# {"status":"ok"}

명령어 모음
┌───────────────┬──────────────────────────────────────────────────────────┬────────────────────────┐
│  make 명령어  │                        직접 실행                         │          설명          │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make run      │ go run cmd/server/main.go                                │ 서버 실행              │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make db-up    │ docker compose up -d                                     │ DB 시작                │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make db-down  │ docker compose down                                      │ DB 중지                │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make db-reset │ docker compose down -v                                   │ DB 중지 + 데이터 삭제  │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make          │ docker exec -it mycard-db psql -U mycard -d mycard -c    │ 테이블 목록 조회       │
│ db-tables     │ "\dt"                                                    │                        │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make          │ docker exec -it mycard-db psql -U mycard -d mycard -c    │ 컬럼 구조 조회         │
│ db-schema     │ "\d payments"                                            │                        │
├───────────────┼──────────────────────────────────────────────────────────┼────────────────────────┤
│ make          │ docker exec -it mycard-db psql -U mycard -d mycard       │ DB 직접 접속 (\q로     │
│ db-connect    │                                                          │ 나가기)                │
└───────────────┴──────────────────────────────────────────────────────────┴────────────────────────┘
프로젝트 구조

mycard-server/
├── cmd/
│   └── server/
│       └── main.go              # 서버 진입점
├── internal/
│   ├── database/
│   │   └── database.go          # DB 연결 및 마이그레이션
│   └── model/
│       └── payment.go           # 결제 내역 모델
├── docker-compose.yml           # 로컬 PostgreSQL
├── Makefile                     # 명령어 단축
├── go.mod                       # Go 모듈 정의
└── go.sum                       # 의존성 체크섬
```
