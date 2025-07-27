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
#   apigw_execution_arn = module.infra.apigw_execution_arn
#   apigw_id            = module.infra.apigw_id
#   apigw_resource_id   = module.infra.apigw_resource_id
#   apigw_method_http   = module.infra.apigw_method_http