

"""
Unit tests for RAGPipeline ingest and query functionality.
"""
from rag.pipeline import RAGPipeline
import io

class DummyFile:
    """
    Mock file object for testing document ingestion.
    """
    filename = 'test.txt'
    file = io.BytesIO(b"This is a test document.")

def test_ingest_document():
    """
    Test document ingestion returns status dict.
    """
    pipeline = RAGPipeline('fake-key', 'fake-env')
    result = pipeline.ingest_document(DummyFile())
    assert isinstance(result, dict)
    assert 'status' in result

def test_answer_query():
    """
    Test query answering returns answer dict.
    """
    pipeline = RAGPipeline('fake-key', 'fake-env')
    result = pipeline.answer_query("What is RAG?", top_k=1)
    assert isinstance(result, dict)
    assert 'answer' in result
