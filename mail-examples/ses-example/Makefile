SHELL=/bin/bash

OPENAPI_SCRIPT=./scripts/run-openapi-docker.sh
OPENAPI_VALIDATION_SCRIPT=./scripts/check-openapi-validation.sh
OPENAPI_PATH=./openapi

run-server:
	swift run SESExample

run-openapi:
	$(OPENAPI_SCRIPT) -n mail-api-ses -p 8888:80 -f "$(OPENAPI_PATH)"

openapi-validation:
	$(OPENAPI_VALIDATION_SCRIPT) -f "$(OPENAPI_PATH)"
