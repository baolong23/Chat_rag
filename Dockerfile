# Ready-to-use Dockerfile for RAG Chatbot (FastAPI)
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY aws/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Set environment variables (can be overridden by .env or at runtime)
ENV PYTHONUNBUFFERED=1

# Expose FastAPI port
EXPOSE 8000

# Start FastAPI app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
