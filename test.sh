#!/bin/bash
set -e

LOCAL_REPORTS_DIR="./reports"
BUCKET_NAME="fcp-mpdp-performance-test-suite"

echo "Starting fcp-mpdp-performance-test-suite Docker container..."
docker compose up --build -d 

echo "Creating S3 bucket: $BUCKET_NAME..."
docker compose exec development aws --endpoint-url=http://localstack:4566 s3 mb "s3://$BUCKET_NAME" 
echo "S3 bucket: $BUCKET_NAME successfully created"

echo "Clearing local reports directory: $LOCAL_REPORTS_DIR"
rm -rf "${LOCAL_REPORTS_DIR:?}"/*
mkdir -p "$LOCAL_REPORTS_DIR"

echo "Downloading reports from S3 bucket $BUCKET_NAME..."
docker compose exec development aws s3 cp "s3://$BUCKET_NAME/" "/opt/perftest/reports" --recursive --endpoint-url=http://localstack:4566

echo "Reports have been downloaded successfully"
