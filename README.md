# RAG Chatbot System

A professional Retrieval-Augmented Generation (RAG) chatbot system using Langchain (2025), Pinecone, FastAPI, and AWS Lambda/S3/SQS with Terraform IaC. Supports multiple document types (pdf, png, csv, txt, etc).

## Features
- Langchain for RAG and document processing
- Pinecone vector database for embeddings
- FastAPI for chatbot API
- AWS Lambda, S3, SQS for scalable request processing (Terraform IaC)
- Design patterns for maintainability
- Supports PDF, PNG, CSV, TXT, and more

## Structure
- `app/` - FastAPI app and API logic (entrypoint, routes)
- `app/api/` - API route handlers
- `rag/` - RAG pipeline, Langchain, Pinecone integration
- `modules/` - Service classes (RAGService, etc.)
- `aws/` - Terraform IaC for Lambda, S3, SQS
- `docs/` - Documentation
- `tests/` - Unit and integration tests

## Quick Start
1. Install dependencies
2. Configure AWS and Pinecone
3. Run FastAPI server

See docs/ for more details.
