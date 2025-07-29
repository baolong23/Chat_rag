#!/bin/bash
# ECR-based AWS Lambda deployment script for SQS Worker
# Usage: ./app/sqs_build/deploy_sqs_worker_ecr.sh
set -e

PROJECT_ROOT=$(dirname $(dirname "$0"))
ECR_REPO=sqs-worker-lambda
IMAGE_TAG=0.0.1
LAMBDA_NAME=sqs-worker
AWS_REGION=us-east-1

cd "$PROJECT_ROOT"

# Build Docker image for SQS Worker
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.$AWS_REGION.amazonaws.com
ECR_URI=$(aws ecr describe-repositories --repository-names $ECR_REPO --region $AWS_REGION --query "repositories[0].repositoryUri" --output text)
docker build --platform linux/amd64 --provenance=false -t $ECR_REPO:$IMAGE_TAG . 
docker tag $ECR_REPO:$IMAGE_TAG $ECR_URI:$IMAGE_TAG

docker push $ECR_URI:$IMAGE_TAG