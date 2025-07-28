from setuptools import setup,find_packages

setup(
    name="chatbot_rag_system",
    version="0.1.0",
    description="Modular chatbot system with LangChain-based RAG and Pinecone integration",
    author="HBLong",
    packages=find_packages(where="."),
    install_requires=[      
        "boto3",
        "pinecone-client",
        "langchain",
        "langchain-google-genai>=1.0.5",
        "fastapi",
        "mangum",
        "PyPDF2"
        "pytesseract",
        "Pillow",
        "pandas",
        "langchain-community>=0.0.38"        
    ],
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.10",
)
