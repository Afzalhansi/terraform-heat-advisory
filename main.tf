terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

resource "aws_s3_bucket" "heat_advisory" {
  bucket = "uae-heat-advisory-afzal"
}

resource "aws_s3_bucket_website_configuration" "heat_advisory" {
  bucket = aws_s3_bucket.heat_advisory.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "heat_advisory" {
  bucket = aws_s3_bucket.heat_advisory.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "heat_advisory" {
  bucket = aws_s3_bucket.heat_advisory.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.heat_advisory.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.heat_advisory]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.heat_advisory.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

output "website_url" {
  value = aws_s3_bucket_website_configuration.heat_advisory.website_endpoint
}
