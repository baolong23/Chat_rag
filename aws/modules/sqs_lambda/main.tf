resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "sqs_worker" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"
  image_uri     = "${var.ecr_url}:${var.image_tag}"
  memory_size   = 1024

  environment {
    variables = {
      SQS_QUEUE_URL = var.sqs_id
      PINECONE_API_KEY = var.pinecone_api_key
      PINECONE_ENV     = var.pinecone_env
      BUCKET_NAME      = var.bucket_name
      GOOGLE_API_KEY   = var.google_api_key
    }
    }
  timeout = 120
}

# Policy inline gán luôn vào role Lambda
resource "aws_iam_role_policy" "lambda_sqs_events" {
  name = "lambda-sqs-events-policy"
  role = aws_iam_role.lambda_exec.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = var.sqs_arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_arn
  function_name    = aws_lambda_function.sqs_worker.arn
  batch_size       = 10
  enabled          = true
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "sqs_lambda_policy"
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

resource "aws_lambda_permission" "allow_s3_sqs_worker" {
  statement_id  = "AllowExecutionFromS3SqsService"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sqs_worker.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_arn
}
