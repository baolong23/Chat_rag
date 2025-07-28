import pinecone
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends
from pydantic import BaseModel
from rag.pipeline import RAGPipeline
import os
from typing import Optional
import boto3

from langchain_google_genai import GoogleGenerativeAIEmbeddings,ChatGoogleGenerativeAI

router = APIRouter()

class QueryRequest(BaseModel):
    """
    Request model for query endpoint.
    """
    query: str
    top_k: Optional[int] = 3

def get_pipeline():
    """
    Dependency injector for RAGPipeline.
    """
    pinecone_api_key = os.environ.get('PINECONE_API_KEY')
    # pinecone_env = os.environ.get('PINECONE_ENV')
    if not pinecone_api_key:
        raise HTTPException(status_code=500, detail="Pinecone configuration missing")
    return RAGPipeline(pinecone_api_key)
google_apikey = os.environ.get("GOOGLE_API_KEY")

@router.get("/")
async def start():
    return {"status": "connected"}


@router.post("/ingest")
async def ingest(file: UploadFile = File(...)):
    """
    Ingest a document by uploading to S3 and sending an SQS message for processing.
    """
    bucket_name = os.environ.get('BUCKET_NAME', 'rag-documents-bucket')
    sqs_queue_url = os.environ.get('SQS_QUEUE_URL')
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")
    try:
        s3 = boto3.client('s3')
        print(s3)
        s3_key = f"uploads/{file.filename}"
        print(s3_key)
        s3.upload_fileobj(file.file, bucket_name, s3_key)
        # Send SQS message for worker to process
        if not sqs_queue_url:
            raise HTTPException(status_code=500, detail="SQS queue URL not configured")
        sqs = boto3.client('sqs')
        msg_body = {
            "bucket": bucket_name,
            "key": s3_key,
            "filename": file.filename
        }
        import json
        sqs.send_message(QueueUrl=sqs_queue_url, MessageBody=json.dumps(msg_body))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"S3/SQS operation failed: {str(e)}")
    return {"status": "uploaded to S3 and queued for processing", "s3_key": s3_key}

@router.post("/query")
async def query(request: QueryRequest, pipeline: RAGPipeline = Depends(get_pipeline)):
    """
    Answer a user question using RAG pipeline.
    """
    try:
        embedder = GoogleGenerativeAIEmbeddings( model="models/embedding-001", google_api_key=google_apikey )
        llm = ChatGoogleGenerativeAI(model="gemini-2.5-flash", api_key=google_apikey)
        if not request.query:
            raise HTTPException(status_code=400, detail="Query string required")
        return pipeline.answer_query(embedder,llm,request.query, request.top_k or 3)
    except Exception as e:
        print(f"[ERROR] Query failed: {e}")
        raise HTTPException(status_code=500, detail=f"{str(e)}")
