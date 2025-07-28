variable "lambda_function_name" {
  type    = string
  default = "sqs-worker"
}

variable "image_tag" {
  type        = string
  description = "Tag của Docker image (commit SHA hoặc 'stub')."
  default     = "0.0.1"
}

variable "sqs_arn" {
  type = string
  description = "SQS ARN from infra module"
  default = "arn:aws:sqs:us-east-1:603022906913:rag-queue"
}

variable "sqs_id" {
  type = string
  description = "SQS ID from infra module"
  default = "https://sqs.us-east-1.amazonaws.com/603022906913/rag-queue"
}
variable "ecr_url" {
    type = string
    default = "603022906913.dkr.ecr.us-east-1.amazonaws.com/sqs-worker-lambda"
}
variable "bucket_name" {
    default = "rag-documents-bucket-0316e4ec"
}
variable "s3_arn" {
    default = "arn:aws:s3:::rag-documents-bucket-0316e4ec"
}




variable "pinecone_api_key" {
  description = "Pinecone API Key"
  type        = string
  default = "pcsk_3Tx7pD_4SftcLZWEjjZEoUiLnUw1vDFVXWHMndLuMh6WXrpbT12JL8MNfCA3u71dxxiqfw"
}

variable "google_api_key" {
  description = "Google API Key"
  type        = string
  default = "AIzaSyCsekfaCCMGPbRTicrqz8ylRT1aEOf-mzc"
}

variable "pinecone_env" {
  description = "Pinecone Environment"
  type        = string
  default = "value"
}