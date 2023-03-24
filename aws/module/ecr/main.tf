resource "aws_ecr_repository" "object-detection" {
  name = "object-detection"
}

resource "aws_ecr_repository" "face_detection" {
  name = "face_detection"
}
