variable "aws_region" {
  description = "AWS 리전"
  type = string
  default = "ap-northeast-2"
}

variable "project_name" {
  description = "프로젝트 이름 (리소스 네이밍에 사용)"
  type = string
  default = "mycard"
}

variable "db_username" {
  description = "RDS 데이터베이스 사용자명"
  type = string
  default = "mycard"    
}

variable "db_password" {
  description = "RDS 데이터베이스 비밀번호"
  type = string
  sensitive = true
}