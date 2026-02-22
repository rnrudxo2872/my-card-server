output "alb_dns_name" {
  description = "ALB DNS 이름 (API 접속 URL)"
  value = aws_lb.main.dns_name
}