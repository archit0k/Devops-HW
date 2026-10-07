resource "aws_s3_bucket" "homework" {
  bucket = var.bucket_name
  tags   = { Project = "devops-homework18", Owner = "Archit-Kulkarni", Roll = "24BCS10194" }
}
resource "aws_s3_bucket_public_access_block" "homework" {
  bucket                  = aws_s3_bucket.homework.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_server_side_encryption_configuration" "homework" {
  bucket = aws_s3_bucket.homework.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}
