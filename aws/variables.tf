variable "lambda_image_uri" {
  description = "URI of the Lambda container image in ECR"
  type        = string
}

variable "pinecone_api_key" {
  description = "Pinecone API Key"
  type        = string
}

variable "pinecone_env" {
  description = "Pinecone Environment"
  type        = string
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue for document processing"
  type        = string
  default     = "rag-queue"
}
