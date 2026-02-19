# 도커 이미지 저장소 (elastic container registry)
resource "aws_ecr_repository" "main" {
  name = "${var.project_name}-server"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  tags = {
    Name = "${var.project_name}-server"
  }
}