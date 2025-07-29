#!/bin/bash

# Lambda deployment package build script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
BUILD_DIR="$SCRIPT_DIR/build"
ZIP_FILE="$SCRIPT_DIR/terraform/rds_auto_scheduler.zip"

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Install dependencies
pip install -r "$SRC_DIR/requirements.txt" -t "$BUILD_DIR"

# Copy Lambda function and configuration
cp "$SRC_DIR/lambda_function.py" "$BUILD_DIR/"
cp "$SRC_DIR/custom_holidays.json" "$BUILD_DIR/"

# Create zip file
cd "$BUILD_DIR"
zip -r "$ZIP_FILE" .

echo "Lambda deployment package created: $ZIP_FILE"