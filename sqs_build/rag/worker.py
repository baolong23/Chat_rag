"""
SQSWorker for polling SQS and processing documents from S3.
"""

import os
import json
import boto3
from modules.rag_service import RAGService  # chỉnh lại import theo structure của bạn

# Khởi tạo client/layer bên ngoài handler để reuse connection
pinecone_api_key = os.getenv("PINECONE_API_KEY")
pinecone_env     = os.getenv("PINECONE_ENV")
index_name       = os.getenv("PINECONE_INDEX", "rag-index")
rag_service      = RAGService(pinecone_api_key, pinecone_env, index_name)

def lambda_handler(event, context):
    """
    Lambda handler dùng SQS Event Source Mapping.
    event['Records'] là list các messages từ SQS.
    """
    for record in event.get("Records", []):
        try:
            # Nếu bạn dùng FIFO queue, body có thể nested bên trong
            body = record.get("body")
            if isinstance(body, str):
                body = json.loads(body)
            
            bucket   = body["bucket"]
            key      = body["key"]
            filename = body.get("filename", key.split("/")[-1])
            
            # Process document
            result = rag_service.process_document_from_s3(bucket, key, filename)
            print(f"[SUCCESS] Indexed document: {filename}")
        
        except Exception as e:
            # Nếu có exception, Lambda sẽ tự retry theo cấu hình Event Source Mapping
            print(f"[ERROR] Processing record {record.get('messageId')}: {e}", flush=True)
            
            # Tuỳ chọn: gửi error sang DLQ hoặc external logging
            # raise e  # uncomment nếu muốn Lambda throw và retry
        
    # Nếu hết loop mà không có raise, Lambda sẽ delete hết các message thành công
    return {
        "statusCode": 200,
        "body": json.dumps({"processed": len(event.get("Records", []))})
    }
