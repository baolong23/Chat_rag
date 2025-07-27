#!/bin/bash
# ECR-based AWS Lambda deployment script
# Usage: ./aws/deploy_lambda_ecr.sh

set -e

PROJECT_ROOT=$(dirname $(dirname "$0"))
ECR_REPO=rag-lambda
IMAGE_TAG=0.0.4
LAMBDA_NAME=rag_service
AWS_REGION=us-east-1

cd "$PROJECT_ROOT"

# Build Docker image
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com
ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION --query "repositories[0].repositoryUri" --output text)
docker build --no-cache -t $ECR_REPO:$IMAGE_TAG .
docker tag $ECR_REPO:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

docker push $ECR_URI:$IMAGE_TAG

# # Update Lambda to use new image
aws lambda update-function-code --function-name $LAMBDA_NAME --image-uri $ECR_URI:$IMAGE_TAG --region $AWS_REGION

echo "ECR-based Lambda deployment complete."
