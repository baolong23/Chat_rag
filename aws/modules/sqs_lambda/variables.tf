variable "lambda_function_name" {
  type    = string
  default = "sqs-worker"
}

variable "image_tag" {
  type        = string
  description = "Tag của Docker image (commit SHA hoặc 'stub')."
  default     = "0.0.1"
}

variable "sqs_arn" {}

variable "sqs_id" {}
variable "ecr_url" {}
variable "bucket_name" {}
variable "s3_arn" {}


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