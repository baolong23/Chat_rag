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
        self.embedder = None
        self.llm = None
        self.text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)

        

    def process_document_from_s3(self, bucket: str, key: str, filename: str) -> dict:
        """
        Download document from S3 and process for embedding and indexing.
        """
        s3 = boto3.client('s3')
        ext = os.path.splitext(filename)[1].lower()
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            s3.download_fileobj(bucket, key, tmp)
            tmp_path = tmp.name
        return self._process_and_index(tmp_path, filename, ext)

    def ingest_document(self, file: UploadFile) -> dict:
        """
        Ingest document uploaded via FastAPI endpoint.
        """
        ext = os.path.splitext(file.filename)[1].lower()
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            tmp.write(file.file.read())
            tmp_path = tmp.name
        return self._process_and_index(tmp_path, file.filename, ext)

    def _process_and_index(self, path: str, filename: str, ext: str) -> dict:
        """
        Load, split, embed, and index document chunks in Pinecone.
        """
        text = DocumentLoaderFactory.load(path, ext)
        chunks = self.text_splitter.split_text(text)
        embeddings = self.embedder.embed_documents(chunks)
        vectors = [(f"{filename}-{i}", emb, {"text": chunk}) for i, (chunk, emb) in enumerate(zip(chunks, embeddings))]
        self.index.upsert(vectors)
        return {"status": "document ingested", "chunks": len(chunks)}

    def answer_query(self,embedder, llm, query: str, top_k: int = 3) -> dict:
        """
        Answer user query using indexed document context and LLM.
        """
        query_embedding = embedder.embed_query(query)
        results = self.index.query(vector=query_embedding, top_k=top_k, include_metadata=True)
        context = "\n".join([match["metadata"]["text"] for match in results["matches"]])
        prompt = f"Context:\n{context}\n\nQuestion: {query}\nAnswer:"
        answer = llm.invoke(prompt)
        return {"answer": answer, "context": context}
