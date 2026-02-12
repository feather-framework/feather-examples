SHELL=/bin/bash

#baseUrl = https://raw.githubusercontent.com/BinaryBirds/github-workflows/refs/heads/main/scripts


## params: -n: name, -p: port
run-openapi:
	./run-openapi-docker.sh -n mail-api

openapi-security:
	./check-openapi-security.sh

openapi-validation:
	./check-openapi-validation.sh