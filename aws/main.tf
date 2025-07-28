module "infra" {
  source = "./modules/infra"
}

module "lambda" {
  source                = "./modules/lambda"
  bucket_name         = module.infra.bucket_name
  sqs_arn             = module.infra.sqs_arn
  ecr_url             = module.infra.ecr_url
  sqs_rag_id          = module.infra.sqs_rag_id
  s3_arn              = module.infra.s3_arn
}
# Thêm module sqs_lambda cho worker SQS
module "sqs_lambda" {
  source      = "./modules/sqs_lambda"
  sqs_arn     = module.infra.sqs_arn
  sqs_id      = module.infra.sqs_rag_id
  ecr_url     = module.infra.ecr_sqs_url
  bucket_name = module.infra.bucket_name
  s3_arn = module.infra.s3_arn
}
