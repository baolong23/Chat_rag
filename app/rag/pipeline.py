"""
RAGPipeline: Facade for document ingest, embedding, and query answering.
"""
import os
from modules.rag_service import RAGService


class RAGPipeline:
    """
    Facade for RAGService, provides ingest and query methods for API and workers.
    """
    def __init__(self, pinecone_api_key: str, pinecone_env: str = "", index_name: str = "rag-index"):
        self.rag_service = RAGService(pinecone_api_key, pinecone_env, index_name)

    def ingest_document(self, file) -> dict:
        """
        Ingest document using RAGService.
        """
        return self.rag_service.ingest_document(file)
    
    def get_document(self) -> list:
        return self.rag_service.get_document()

    def answer_query(self, embedder, llm, query: str, top_k: int = 3, name_space:str ="") -> dict:
        """
        Answer query using RAGService.
        """
        return self.rag_service.answer_query(embedder,llm,query, top_k, name_space)
    
