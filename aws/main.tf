
# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# SQS queue for document processing
resource "aws_sqs_queue" "rag_queue" {
  name = var.sqs_queue_name
}


# S3 bucket for document storage
resource "aws_s3_bucket" "documents" {
  bucket = "rag-documents-bucket"
}


# IAM role for Lambda execution
resource "aws_iam_role" "lambda_exec" {
  name = "rag_lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}


# IAM policy for Lambda to access S3 and CloudWatch Logs
resource "aws_iam_role_policy" "lambda_policy" {
  name = "rag_lambda_policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.documents.arn,
          "${aws_s3_bucket.documents.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

# IAM policy for Lambda to access SQS
resource "aws_iam_role_policy" "lambda_sqs_policy" {
  name = "rag_lambda_sqs_policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.rag_queue.arn
      }
    ]
  })
}


# Lambda function (container image version recommended for FastAPI)
resource "aws_lambda_function" "rag_service" {
  function_name = "rag_service"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = var.lambda_image_uri # Set this variable in your terraform.tfvars or pipeline
  timeout       = 120
  environment {
    variables = {
      PINECONE_API_KEY = var.pinecone_api_key
      PINECONE_ENV     = var.pinecone_env
      BUCKET_NAME      = aws_s3_bucket.documents.bucket
      SQS_QUEUE_URL    = aws_sqs_queue.rag_queue.id
    }
  }
}


# S3 triggers Lambda on document upload
# resource "aws_s3_bucket_notification" "notify_rag_service" {
#   bucket = aws_s3_bucket.documents.id
#   lambda_function {
#     lambda_function_arn = aws_lambda_function.rag_service.arn
#     events              = ["s3:ObjectCreated:*"]
#     filter_prefix       = "uploads/"
#   }
#   depends_on = [aws_lambda_function.rag_service]
# }


resource "aws_lambda_permission" "allow_s3_rag_service" {
  statement_id  = "AllowExecutionFromS3RagService"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rag_service.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.documents.arn
}


# API Gateway for FastAPI Lambda
resource "aws_api_gateway_rest_api" "rag_api" {
  name        = "rag-service-api"
  description = "API Gateway for RAG question answering service"
}

# Outputs
output "api_gateway_url" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.rag_api.execution_arn
}

output "s3_bucket_name" {
  description = "S3 bucket name for documents"
  value       = aws_s3_bucket.documents.bucket
}

output "sqs_queue_url" {
  description = "SQS queue URL for document processing"
  value       = aws_sqs_queue.rag_queue.id
}


resource "aws_api_gateway_resource" "query" {
  rest_api_id = aws_api_gateway_rest_api.rag_api.id
  parent_id   = aws_api_gateway_rest_api.rag_api.root_resource_id
  path_part   = "query"
}


resource "aws_api_gateway_method" "query_post" {
  rest_api_id   = aws_api_gateway_rest_api.rag_api.id
  resource_id   = aws_api_gateway_resource.query.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "rag_service_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rag_api.id
  resource_id             = aws_api_gateway_resource.query.id
  http_method             = aws_api_gateway_method.query_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rag_service.invoke_arn
}


resource "aws_lambda_permission" "allow_apigw_rag_service" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rag_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_rest_api.rag_api.execution_arn
}