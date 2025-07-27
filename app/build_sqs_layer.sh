#!/bin/bash
set -e

# --- Xác định thư mục gốc script và build ---
# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# BUILD_DIR="${SCRIPT_DIR}/build"
# LAYER_PY_DIR="${BUILD_DIR}/layer/python"

# # Tên file zip
# LAYER_ZIP="${BUILD_DIR}/layer.zip"
# LAMBDA_ZIP="${BUILD_DIR}/lambda.zip"

echo "[+] SCRIPT_DIR  = $SCRIPT_DIR"
echo "[+] BUILD_DIR   = $BUILD_DIR"
echo "[+] LAYER_PY_DIR= $LAYER_PY_DIR"


LAYER_DIR="sqs_build/layer"
LAMBDA_DIR="sqs_build/lambda"

echo "[+] Cleaning old builds..."
# rm -rf build
mkdir -p ${LAYER_DIR}/python
mkdir -p ${LAMBDA_DIR}

echo "[+] Installing dependencies to Lambda Layer..."
python3 -m pip install --no-user -r requirements.txt -t ${LAYER_DIR}/python/lib/python3.10/site-packages > /dev/null


echo "[+] Copying source code to Lambda bundle..."
cp -r modules ${LAMBDA_DIR}/
cp rag/worker.py ${LAMBDA_DIR}/


echo "[+] Zipping Lambda Function..."
python sqs_build/build_zip.py "$LAMBDA_DIR" "$LAMBDA_ZIP"
echo "[+] Zipping Lambda Layer..."
python sqs_build/build_zip.py "$LAYER_DIR" "$LAYER_ZIP"


echo "[✓] Build complete:"
echo " - build/layer.zip (layer dependencies)"
echo " - build/lambda.zip (lambda function)"
rm -rf ${LAMBDA_DIR}
rm -rf ${LAYER_DIR}
