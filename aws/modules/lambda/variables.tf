variable "lambda_image_uri" {
  description = "URI of the Lambda container image in ECR"
  type        = string
  default = "public.ecr.aws/lambda/python:3.12"
}

variable "image_tag" {
  type        = string
  description = "Tag của Docker image (commit SHA hoặc 'stub')."
  default     = "0.0.4"
}


variable "pinecone_api_key" {
  description = "Pinecone API Key"
  type        = string
  default = "[PUT PINECONE API KEY HERE]"
}

variable "google_api_key" {
  description = "Google API Key"
  type        = string
  default = "[PUT GOOGLE API KEY HERE]"
}

variable "pinecone_env" {
  description = "Pinecone Environment"
  type        = string
  default = "value"
}

variable "sqs_queue_name" {
  description = "Name of the SQS queue for document processing"
  type        = string
  default     = "rag-queue"
}
variable "bucket_name" {}
variable "sqs_arn" {}
variable "ecr_url" {}
# variable "apigw_execution_arn" {}
# variable "apigw_id" {}
# variable "apigw_resource_id" {}
# variable "apigw_method_http" {}
variable "sqs_rag_id" {}
variable "s3_arn" {}