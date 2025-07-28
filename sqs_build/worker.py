"""
SQSWorker for polling SQS and processing documents from S3.
"""
import os
import os
import json
import boto3
from modules.rag_service import RAGService

pinecone_api_key = os.getenv("PINECONE_API_KEY")
pinecone_env     = os.getenv("PINECONE_ENV")
index_name       = os.getenv("PINECONE_INDEX", "rag-index")

if not pinecone_api_key or not pinecone_env:
    raise RuntimeError("Missing Pinecone API key or environment variable.")

rag_service = RAGService(pinecone_api_key, pinecone_env, index_name)
s3_client = boto3.client("s3")  # Nếu bạn cần dùng S3 client

def lambda_handler(event, context):
    processed = 0
    for record in event.get("Records", []):
        try:
            body = record.get("body")
            if isinstance(body, str):
                body = json.loads(body)
            bucket   = body.get("bucket")
            key      = body.get("key")
            filename = body.get("filename", key.split("/")[-1] if key else "unknown")
            if not bucket or not key:
                print(f"[ERROR] Missing bucket or key in record {record.get('messageId')}")
                continue
            print(f"[INFO] Processing file: s3://{bucket}/{key} (messageId={record.get('messageId')})")
            print(f"FILENAME: {filename}")
            result = rag_service.process_document_from_s3(bucket, key, filename)
            print(f"[SUCCESS] Indexed document: {filename}")
            processed += 1
        except Exception as e:
            print(f"[ERROR] Processing record {record.get('messageId')}: {e}", flush=True)
            # raise e  # Uncomment nếu muốn Lambda retry message lỗi
    return {
        "statusCode": 200,
        "body": json.dumps({"processed": processed})
    }