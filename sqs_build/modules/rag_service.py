import os
import tempfile
from fastapi import UploadFile, HTTPException
from pinecone import Pinecone
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_google_genai import GoogleGenerativeAIEmbeddings,ChatGoogleGenerativeAI

# from langchain.llms import Gemini
from rag.loaders import DocumentLoaderFactory
import boto3

google_apikey = os.environ.get("GOOGLE_API_KEY")

class RAGService:
    """
    Facade for RAG operations: ingest, process, query.
    Handles document ingestion, embedding, and query answering using Langchain and Pinecone.
    """
    def __init__(self, pinecone_api_key: str, pinecone_env: str ="", index_name: str = "rag-index"):
        """
        Initialize RAGService with Pinecone and Langchain components.
        """
        self.pinecone = Pinecone(api_key=pinecone_api_key)
        self.index = self.pinecone.Index(index_name)
        self.embedder = GoogleGenerativeAIEmbeddings( model="models/embedding-001", google_api_key=google_apikey )
        self.text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)

    def process_document_from_s3(self, bucket: str, key: str, filename: str) -> dict:
        """
        Download document from S3 and process for embedding and indexing.
        """
        s3 = boto3.client('s3')
        ext = os.path.splitext(filename)[1].lower()
        with tempfile.NamedTemporaryFile(delete=False, suffix=ext) as tmp:
            s3.download_fileobj(bucket, key, tmp)
            tmp_path = tmp.name
            print(f"Downloaded {filename} to temporary path: {tmp_path}")
            return self._process_and_index(tmp_path, filename, ext)

    def ingest_document(self, file: UploadFile) -> dict:
        """
        Ingest document uploaded via FastAPI endpoint.
        """
        ext = os.path.splitext(file.filename)[1].lower()
        with tempfile.NamedTemporaryFile(delete=False,  suffix=ext) as tmp:
            tmp.write(file.file.read())
            tmp_path = tmp.name
        return self._process_and_index(f"${tmp_path}.ext", file.filename, ext)

    def _process_and_index(self, path: str, filename: str, ext: str) -> dict:
        """
        Load, split, embed, and index document chunks in Pinecone.
        """
        text = DocumentLoaderFactory.load(path, ext)
        chunks = self.text_splitter.split_text(text)
        embeddings = self.embedder.embed_documents(chunks)
        vectors = [
            {
                "id": f"{filename}-{i}",
                "values": emb,
                "metadata": {"text": chunk}
            }
            for i, (chunk, emb) in enumerate(zip(chunks, embeddings))
        ]

        self.index.upsert(vectors=vectors, namespace=filename)

        return {"status": "document ingested", "chunks": len(chunks)}