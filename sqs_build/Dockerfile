# Ready-to-use Dockerfile for RAG Chatbot (FastAPI)
FROM public.ecr.aws/lambda/python:3.10

WORKDIR ${LAMBDA_TASK_ROOT}


# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"


# Copy project files
COPY . .

# Start FastAPI app
CMD ["worker.lambda_handler"]
