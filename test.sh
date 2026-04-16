#!/bin/bash
set -e

LOCAL_REPORTS_DIR="./reports"

# Clean up any existing reports using Docker (handles root-owned files)
if [ -d "$LOCAL_REPORTS_DIR" ]; then
  echo "Cleaning existing reports directory..."
  docker run --rm -v "$(pwd)/reports:/reports" alpine sh -c "rm -rf /reports/*" 2>/dev/null || true
fi

mkdir -p -m 777 "$LOCAL_REPORTS_DIR"

docker compose down -v
docker compose up --build -d

echo "Waiting for JMeter tests to complete..."
# Wait for the development container to finish running tests
timeout=900  # 15 minutes timeout for tests
counter=0
while [ $counter -lt $timeout ]; do
  # Check if container is still running (tests ongoing)
  if docker compose ps development --format "table {{.Status}}" | grep -q "Up"; then
    echo "⏳ JMeter tests still running... ($counter/$timeout seconds)"
    sleep 10
    counter=$((counter + 10))
  else
    # Container has finished
    exit_code=$(docker compose ps development --format "table {{.Status}}" | grep -o "Exited ([0-9]*)" | grep -o "[0-9]*" || echo "0")
    if [ "$exit_code" = "0" ]; then
      echo "✅ JMeter tests completed successfully!"
      break
    else
      echo "❌ JMeter tests failed with exit code: $exit_code"
      docker compose logs development
      exit 1
    fi
  fi
done

if [ $counter -ge $timeout ]; then
  echo "❌ JMeter tests timed out after $timeout seconds"
  docker compose logs development
  exit 1
fi

echo "Preparing local reports directory: $LOCAL_REPORTS_DIR"
mkdir -p "$LOCAL_REPORTS_DIR"

# Check if reports were generated in the mounted volume
if [ -f "./reports/index.html" ]; then
  echo "✅ Performance test reports are ready!"
  echo "📊 View the report at: file://$(pwd)/reports/index.html"
  echo "📁 All report files are in: $(pwd)/reports/"
  
  # List the available reports
  echo ""
  echo "Available report files:"
  ls -la ./reports/
else
  echo "❌ No report files found in mounted volume. Checking container logs..."
  docker compose logs development
  exit 1
fi

echo ""
echo "🎉 Performance test suite execution completed successfully!"
echo "🌐 Open the HTML report in your browser to view detailed results"
