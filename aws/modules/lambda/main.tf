# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# API Gateway for FastAPI Lambda
resource "aws_api_gateway_rest_api" "rag_api" {
  name        = "rag-service-api"
  description = "API Gateway for RAG question answering service"
}

resource "aws_api_gateway_resource" "query" {
  rest_api_id = "${aws_api_gateway_rest_api.rag_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.rag_api.root_resource_id}"
  path_part   = "query"
}


resource "aws_api_gateway_method" "query_post" {
  rest_api_id   = "${aws_api_gateway_rest_api.rag_api.id}"
  resource_id   = "${aws_api_gateway_resource.query.id}"
  http_method   = "POST"
  authorization = "NONE"
}

# Outputs
output "api_gateway_url" {
  description = "API Gateway execution ARN"
  value       = aws_api_gateway_rest_api.rag_api.execution_arn
}


# Lambda function (container image version recommended for FastAPI)
resource "aws_lambda_function" "rag_service" {
  function_name = "rag_service"
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     =  "${var.ecr_url}:${var.image_tag}"#var.lambda_image_uri # Set this variable in your terraform.tfvars or pipeline
  timeout       = 120
  environment {
    variables = {
      PINECONE_API_KEY = var.pinecone_api_key
      PINECONE_ENV     = var.pinecone_env
      BUCKET_NAME      = var.bucket_name
      SQS_QUEUE_URL    = var.sqs_rag_id
      GOOGLE_API_KEY   = var.google_api_key
    }
  }
}


resource "aws_api_gateway_integration" "rag_service_integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.rag_api.id}"
  resource_id             = "${aws_api_gateway_resource.query.id}"
  http_method             = "${aws_api_gateway_method.query_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.rag_service.invoke_arn}"
}

resource "aws_lambda_permission" "allow_apigw_rag_service" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.rag_service.function_name}"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rag_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "rag_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rag_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rag_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on  = [aws_api_gateway_integration.rag_service_integration]
}

resource "aws_api_gateway_stage" "rag_api_stage" {
  deployment_id = aws_api_gateway_deployment.rag_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rag_api.id
  stage_name    = "dev"
}


# resource "aws_api_gateway_deployment" "rag_api_deploy" {
#   depends_on = [
#     "aws_api_gateway_integration.lambda",
#     "aws_api_gateway_integration.lambda_root",
#   ]

#   rest_api_id = "${aws_api_gateway_rest_api.rag_api.id}"
#   stage_name  = "test"
# }


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
          var.s3_arn,
          "${var.s3_arn}/*"
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
        Resource = var.sqs_arn
      }
    ]
  })
}

resource "aws_lambda_permission" "allow_s3_rag_service" {
  statement_id  = "AllowExecutionFromS3RagService"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rag_service.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_arn
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

