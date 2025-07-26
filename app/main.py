

"""
FastAPI app entrypoint for AWS Lambda (Mangum handler).
Initializes FastAPI app and exposes handler for Lambda integration.
"""
from fastapi import FastAPI
from mangum import Mangum
from app.api.routes import router

# Create FastAPI app
app = FastAPI()
app.include_router(router)

# Expose handler for AWS Lambda
handler = Mangum(app)
