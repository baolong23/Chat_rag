# Ready-to-use Dockerfile for RAG Chatbot (FastAPI)
FROM public.ecr.aws/lambda/python:3.10

WORKDIR ${LAMBDA_TASK_ROOT}
# COPY main.py ${LAMBDA_TASK_ROOT}/
# RUN apt-get -y update
# RUN apt-get -y upgrade

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"


# Copy project files
COPY . .

# Set environment variables (can be overridden by .env or at runtime)
# ENV PYTHONUNBUFFERED=1

# Expose FastAPI port
# EXPOSE 8000
# ENTRYPOINT ["python3", "-m", "awslambdaric"]

# Start FastAPI app
CMD ["main.handler"]
