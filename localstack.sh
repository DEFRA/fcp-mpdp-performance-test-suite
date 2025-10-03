#!/usr/bin/env sh

echo "configuring s3 buckets for performance test suite"
echo "================================================="
LOCALSTACK_HOST=localhost
AWS_REGION=eu-west-2

create_bucket() {
  local BUCKET_NAME_TO_CREATE=$1
  echo "Creating S3 bucket: ${BUCKET_NAME_TO_CREATE}"
  awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 s3 mb s3://${BUCKET_NAME_TO_CREATE} --region ${AWS_REGION}
  
  # Verify bucket creation
  if awslocal --endpoint-url=http://${LOCALSTACK_HOST}:4566 s3 ls s3://${BUCKET_NAME_TO_CREATE} > /dev/null 2>&1; then
    echo "✅ S3 bucket '${BUCKET_NAME_TO_CREATE}' created successfully"
  else
    echo "❌ Failed to create S3 bucket '${BUCKET_NAME_TO_CREATE}'"
    exit 1
  fi
}

# Create the bucket for performance test results
create_bucket "fcp-mpdp-performance-test-suite"

echo "S3 setup completed successfully"
