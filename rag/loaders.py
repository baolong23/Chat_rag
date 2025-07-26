"""
DocumentLoaderFactory and individual loaders for supported file types.
"""
import os
from fastapi import HTTPException


class DocumentLoaderFactory:
    """
    Factory for loading supported document types.
    """
    @staticmethod
    def load(path: str, ext: str) -> str:
        if ext == '.pdf':
            return PDFLoader.load(path)
        elif ext == '.png':
            return PNGLoader.load(path)
        elif ext == '.csv':
            return CSVLoader.load(path)
        elif ext == '.txt':
            return TXTLoader.load(path)
        else:
            raise HTTPException(status_code=400, detail='Unsupported file type')


class PDFLoader:
    """
    Loader for PDF documents.
    """
    @staticmethod
    def load(path: str) -> str:
        from PyPDF2 import PdfReader
        reader = PdfReader(path)
        return "\n".join(page.extract_text() for page in reader.pages)


class PNGLoader:
    """
    Loader for PNG images (OCR).
    """
    @staticmethod
    def load(path: str) -> str:
        import pytesseract
        from PIL import Image
        return pytesseract.image_to_string(Image.open(path))


class CSVLoader:
    """
    Loader for CSV documents.
    """
    @staticmethod
    def load(path: str) -> str:
        import pandas as pd
        df = pd.read_csv(path)
        return df.to_string()


class TXTLoader:
    """
    Loader for TXT documents.
    """
    @staticmethod
    def load(path: str) -> str:
        with open(path, 'r', encoding='utf-8') as f:
            return f.read()
