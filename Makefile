# ──────────────── 서버 ────────────────

## 서버 실행 (로컬 개발용)
run:
	go run cmd/server/main.go

# ──────────────── DB ────────────────

## PostgreSQL 컨테이너 시작
db-up:
	docker compose up -d

## PostgreSQL 컨테이너 중지
db-down:
	docker compose down

## PostgreSQL 컨테이너 중지 + 데이터 삭제
db-reset:
	docker compose down -v

## DB 테이블 목록 확인
db-tables:
	docker exec -it mycard-db psql -U mycard -d mycard -c "\dt"

## DB 컬럼 구조 확인
db-schema:
	docker exec -it mycard-db psql -U mycard -d mycard -c "\d payments"

## payments 테이블 데이터 조회
db-rows:
	docker exec -it mycard-db psql -U mycard -d mycard -c "SELECT * FROM payments"

## DB 직접 접속 (psql 대화형)
db-connect:
	docker exec -it mycard-db psql -U mycard -d mycard


  #Makefile 주의사항:
  # - 각 명령어 앞의 들여쓰기는 반드시 **탭(Tab)**이어야 합니다. 공백(Space)을 쓰면 에러남
  # - 에디터에서 탭이 공백으로 자동 변환되는 경우가 있으니 확인해주세요

# 사용법:

 # make run          # go run cmd/server/main.go
 # make db-up        # docker compose up -d
 # make db-down      # docker compose down
 # make db-reset     # docker compose down -v (데이터 초기화)
 # make db-tables    # 테이블 목록 조회
 # make db-schema    # payments 컬럼 구조 조회
 # make db-connect   # psql 대화형 접속 (\q로 나가기)