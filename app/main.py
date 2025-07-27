

"""
FastAPI app entrypoint for AWS Lambda (Mangum handler).
Initializes FastAPI app and exposes handler for Lambda integration.
"""
import logging
from fastapi import FastAPI
from mangum import Mangum
from api.routes import router
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


import sys
print("PYTHONPATH:", sys.path)
# Create FastAPI app

from fastapi.middleware.cors import CORSMiddleware


app = FastAPI(root_path="/dev")
app.include_router(router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # or restrict to your frontend domain
    allow_methods=["*"],
    allow_headers=["*"],
)

logger.info("FastAPI app initialized, ready to handle requests")

# Expose handler for AWS Lambda
handler = Mangum(app)
