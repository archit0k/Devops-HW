data "aws_availability_zones" "available" { state = "available" }
data "aws_ssm_parameter" "ami" { name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64" }
resource "aws_vpc" "homework" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "archit-homework19-vpc" }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.homework.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = { Name = "homework19-public" }
}
resource "aws_internet_gateway" "homework" { vpc_id = aws_vpc.homework.id }
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.homework.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.homework.id
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "web" {
  name        = "archit-homework19-web"
  description = "Disposable classroom HTTP server; no SSH"
  vpc_id      = aws_vpc.homework.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  metadata_options { http_tokens = "required" }
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 8
  }
  credit_specification { cpu_credits = "standard" }
  user_data  = <<-SCRIPT
    #!/bin/bash
    dnf install -y httpd
    printf '<h1>Archit Kulkarni - Terraform lab</h1><p>24BCS10194 - Section A</p>' > /var/www/html/index.html
    systemctl enable --now httpd
  SCRIPT
  tags       = { Name = "archit-homework19-web" }
  depends_on = [aws_route_table_association.public]
}
resource "aws_s3_bucket" "homework" { bucket = var.bucket_name }
resource "aws_s3_bucket_public_access_block" "homework" {
  bucket                  = aws_s3_bucket.homework.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
