"""
SQSWorker for polling SQS and processing documents from S3.
"""
import os
import json
import tempfile
import boto3
from modules.rag_service import RAGService


class SQSWorker:
    """
    Worker for polling SQS and processing S3 document ingestion tasks.
    """
    def __init__(self, pinecone_api_key: str, pinecone_env: str, sqs_queue_url: str, index_name: str = "rag-index"):
        self.sqs_queue_url = sqs_queue_url
        self.rag_service = RAGService(pinecone_api_key, pinecone_env, index_name)
        self.sqs = boto3.client('sqs')

    def poll_and_process(self) -> None:
        """
        Poll SQS for messages and process documents from S3.
        """
        while True:
            response = self.sqs.receive_message(
                QueueUrl=self.sqs_queue_url,
                MaxNumberOfMessages=1,
                WaitTimeSeconds=10
            )
            messages = response.get('Messages', [])
            for msg in messages:
                try:
                    body = json.loads(msg['Body'])
                    bucket = body['bucket']
                    key = body['key']
                    filename = body['filename']
                    result = self.rag_service.process_document_from_s3(bucket, key, filename)
                    self.sqs.delete_message(
                        QueueUrl=self.sqs_queue_url,
                        ReceiptHandle=msg['ReceiptHandle']
                    )
                    print(f"Processed and indexed: {filename}")
                except Exception as e:
                    print(f"Error processing message: {e}")
                    # Optionally: send to DLQ or log error
