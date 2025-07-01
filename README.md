# fcp-mpdp-performance-test-suite

A JMeter based test runner for the CDP Platform.

- [Licence](#licence)
  - [About the licence](#about-the-licence)

## Build

Test suites are built automatically by the [.github/workflows/publish.yml](.github/workflows/publish.yml) action whenever a change are committed to the `main` branch.
A successful build results in a Docker container that is capable of running your tests on the CDP Platform and publishing the results to the CDP Portal.

## Run

The performance test suites are designed to be run from the CDP Portal.
The CDP Platform runs test suites in much the same way it runs any other service, it takes a docker image and runs it as an ECS task, automatically provisioning infrastructure as required.

## Local Performance Testing with LocalStack

### Build a new Docker image
```
docker build . -t fcp-mpdp-performance-test-suite
```

### Start a LocalStack instance locally
You must be running another service locally that you wish to run performance tests against e.g. starting up the Docker container for `fcp-mpdp-frontend` will create a LocalStack service that can be used to create a dedicated S3 bucket where the reports will be stored.

### Check health of LocalStack instance (optional)
You can run the following command to check LocalStack health and if S3 is up and running:
```
curl http://localhost:4566/_localstack/health
```
Output of the above should contain the following to confirm S3 is running: `"s3": "available"`.
Ensure the port in the above command matches the port exposed for LocalStack by the service you wish to run performance tests against on your local machine.

### Create a LocalStack bucket
```
aws --endpoint-url=http://localhost:4566 s3 mb s3://fcp-mpdp-performance-test-suite-bucket
```

### Run performance tests
```
docker run --name fcp-mpdp-performance-test-suite --rm \
-e S3_ENDPOINT='http://host.docker.internal:4566' \
-e RESULTS_OUTPUT_S3_PATH='s3://fcp-mpdp-performance-test-suite-bucket' \
-e AWS_ACCESS_KEY_ID='test' \
-e AWS_SECRET_ACCESS_KEY='test' \
-e AWS_SECRET_KEY='test' \
-e AWS_REGION='eu-west-2' \
fcp-mpdp-performance-test-suite
```

### View and copy contents of S3 bucket to local directory
```
aws --endpoint-url=http://localhost:4566 s3 ls s3://fcp-mpdp-performance-test-suite-bucket/                                          
aws --endpoint-url=http://localhost:4566 s3 cp s3://fcp-mpdp-performance-test-suite-bucket ./reports --recursive
```

## Licence

THIS INFORMATION IS LICENSED UNDER THE CONDITIONS OF THE OPEN GOVERNMENT LICENCE found at:

<http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3>

The following attribution statement MUST be cited in your products and applications when using this information.

> Contains public sector information licensed under the Open Government licence v3

### About the licence

The Open Government Licence (OGL) was developed by the Controller of Her Majesty's Stationery Office (HMSO) to enable
information providers in the public sector to license the use and re-use of their information under a common open
licence.

It is designed to encourage use and re-use of information freely and flexibly, with only a few conditions.
