

# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# SQS queue for document processing
resource "aws_sqs_queue" "rag_queue" {
  name = var.sqs_queue_name
  visibility_timeout_seconds = 120
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "random_id" "ecr_id" {
  byte_length = 4
}

# S3 bucket for document storage
resource "aws_s3_bucket" "documents" {
  bucket = "rag-documents-bucket-${random_id.bucket_id.hex}"
}


resource "aws_ecr_repository" "lambda_ecr"{
  name = "rag-lambda"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_repository" "lambda_ecr_sqs"{
  name = "sqs-worker-lambda"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}



output "sqs_queue_url" {
  description = "SQS queue URL for document processing"
  value       = aws_sqs_queue.rag_queue.id
}


output "s3_bucket_name" {
  description = "S3 bucket name for documents"
  value       = aws_s3_bucket.documents.bucket
}
output "bucket_name" {
  description = "S3 bucket name for documents"
  value = aws_s3_bucket.documents.bucket
}

output "s3_arn"{
  value = aws_s3_bucket.documents.arn
}

output "sqs_arn" {
  value = aws_sqs_queue.rag_queue.arn
}

output "sqs_rag_id" {
  value = aws_sqs_queue.rag_queue.id
}

output "ecr_url" {
  value = aws_ecr_repository.lambda_ecr.repository_url
}

output "ecr_sqs_url" {
  value = aws_ecr_repository.lambda_ecr_sqs.repository_url
}

# output "apigw_execution_arn" {
#   value = aws_api_gateway_rest_api.rag_api.execution_arn
# }

# output "apigw_id" {
#   value = aws_api_gateway_rest_api.rag_api.id
# }

# output "apigw_resource_id" {
#   value = aws_api_gateway_resource.query.id
# }

# output "apigw_method_http" {
#   value = aws_api_gateway_method.query_post.http_method
# }