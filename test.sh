#!/bin/bash
set -e

LOCAL_REPORTS_DIR="./reports"
BUCKET_NAME="fcp-mpdp-performance-test-suite"

echo "Starting fcp-mpdp-performance-test-suite Docker container..."
docker compose up --build -d 

echo "Checking if S3 bucket exists: $BUCKET_NAME..."
if docker compose exec development aws s3 ls "s3://$BUCKET_NAME" --endpoint-url=http://fcp-mpdp-performance-test-suite-localstack:4566 > /dev/null 2>&1; then
  echo "S3 bucket $BUCKET_NAME already exists, skipping creation"
else
  echo "Creating S3 bucket: $BUCKET_NAME..."
  docker compose exec development aws --endpoint-url=http://fcp-mpdp-performance-test-suite-localstack:4566 s3 mb "s3://$BUCKET_NAME" 
  echo "S3 bucket: $BUCKET_NAME successfully created"
fi

echo "Waiting for S3 bucket $BUCKET_NAME to become accessible..."
for i in {1..10}; do
  if docker compose exec development aws s3 ls "s3://$BUCKET_NAME" --endpoint-url=http://fcp-mpdp-performance-test-suite-localstack:4566 > /dev/null 2>&1; then
    echo "S3 bucket fcp-mpdp-performance-test-suite is now accessible"
    break
  fi
  echo "S3 bucket fcp-mpdp-performance-test-suite is not yet accessible, retrying in 2 seconds..."
  sleep 2
  if [ "$i" -eq 10 ]; then
    echo "ERROR: S3 bucket $BUCKET_NAME is still not accessible after 10 attempts."
    exit 1
  fi
done

echo "Clearing local reports directory: $LOCAL_REPORTS_DIR"
rm -rf "${LOCAL_REPORTS_DIR:?}"/*
mkdir -p "$LOCAL_REPORTS_DIR"

echo "Downloading reports from S3 bucket $BUCKET_NAME..."
docker compose exec development aws s3 cp "s3://$BUCKET_NAME/" "/opt/perftest/reports" --recursive --endpoint-url=http://fcp-mpdp-performance-test-suite-localstack:4566

echo "Reports have been downloaded successfully"
