SHELL=/bin/bash

baseUrl = https://raw.githubusercontent.com/BinaryBirds/github-workflows/refs/heads/main/scripts

check: symlinks language deps lint headers

symlinks:
	curl -s $(baseUrl)/check-broken-symlinks.sh | bash
	
language:
	curl -s $(baseUrl)/check-unacceptable-language.sh | bash
	
deps:
	curl -s $(baseUrl)/check-local-swift-dependencies.sh | bash
	
lint:
	curl -s $(baseUrl)/run-swift-format.sh | bash

format:
	curl -s $(baseUrl)/run-swift-format.sh | bash -s -- --fix

headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash

fix-headers:
	curl -s $(baseUrl)/check-swift-headers.sh | bash -s -- --fix

build:
	swift build

release:
	swift build -c release

clean:
	rm -rf .build

docker:
	docker compose up --build api
