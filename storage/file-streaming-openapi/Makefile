CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(CURRENT_MAKEFILE_PATH)))

SWIFT_OPENAPI_GENERATOR_GIT_URL ?= https://github.com/apple/swift-openapi-generator
SWIFT_OPENAPI_GENERATOR_GIT_TAG ?= 1.10.4
SWIFT_OPENAPI_GENERATOR_CLONE_DIR ?= $(CURRENT_MAKEFILE_DIR)/.swift-openapi-generator
SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION ?= debug
SWIFT_OPENAPI_GENERATOR_BIN := $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)/.build/$(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)/swift-openapi-generator

OPENAPI_YAML_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/openapi
OPENAPI_YAML_PATH ?= $(OPENAPI_YAML_DIRECTORY)/openapi.yaml
OPENAPI_GENERATOR_CONFIG_PATH ?= $(CURRENT_MAKEFILE_DIR)/openapi-generator-config.yaml
OUTPUT_DIRECTORY ?= $(CURRENT_MAKEFILE_DIR)/Sources/FileStreamingOpenAPI/

DOCKER_PATH ?= $(CURRENT_MAKEFILE_DIR)/docker
DOCKER_OPENAPI_PATH ?= $(DOCKER_PATH)/openapi
DOCKER_OPENAPI_WWW_PATH ?= $(DOCKER_OPENAPI_PATH)/www

SWAGGER_UI_URL ?= https://cdn.jsdelivr.net/npm/swagger-ui-dist
SWAGGER_UI_VERSION ?= 5.31.0
SWAGGER_UI_PATH ?= $(DOCKER_OPENAPI_WWW_PATH)/swagger-ui
SWAGGER_UI_JS_PATH ?= $(SWAGGER_UI_PATH)/bundle.min.js
SWAGGER_UI_CSS_PATH ?= $(SWAGGER_UI_PATH)/min.css

.DEFAULT_GOAL := help

.PHONY: help run generate build dump yaml swagger-ui

help:
	@-+echo "Run make with one of the following targets:"
	@-+echo
	@-+echo "  run:           Run the generator to create YAML and Swift sources."
	@-+grep -Eh "^[a-z-]+:.*#" $(CURRENT_MAKEFILE_PATH) | sed -E 's/^(.*:)(.*#+)(.*)/  \1 @@@ \3 /' | column -t -s "@@@"

run: yaml generate swagger-ui

generate: $(SWIFT_OPENAPI_GENERATOR_BIN) $(OPENAPI_YAML_PATH) $(OPENAPI_GENERATOR_CONFIG_PATH) $(OUTPUT_DIRECTORY)  # Generate OpenAPI sources.
	$< generate \
		--config "$(OPENAPI_GENERATOR_CONFIG_PATH)" \
		--output-directory "$(OUTPUT_DIRECTORY)" \
		"$(OPENAPI_YAML_PATH)"

build:  # Runs swift build.
	swift build

dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "SWIFT_OPENAPI_GENERATOR_GIT_URL = $(SWIFT_OPENAPI_GENERATOR_GIT_URL)"
	@echo "SWIFT_OPENAPI_GENERATOR_GIT_TAG = $(SWIFT_OPENAPI_GENERATOR_GIT_TAG)"
	@echo "SWIFT_OPENAPI_GENERATOR_CLONE_DIR = $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)"
	@echo "SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION = $(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)"
	@echo "SWIFT_OPENAPI_GENERATOR_BIN = $(SWIFT_OPENAPI_GENERATOR_BIN)"
	@echo "OPENAPI_YAML_PATH = $(OPENAPI_YAML_PATH)"
	@echo "OPENAPI_GENERATOR_CONFIG_PATH = $(OPENAPI_GENERATOR_CONFIG_PATH)"
	@echo "OUTPUT_DIRECTORY = $(OUTPUT_DIRECTORY)"

yaml: $(OPENAPI_YAML_DIRECTORY)
	@cd generator && swift run

$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR):
	git \
		-c advice.detachedHead=false \
		clone \
		--branch "$(SWIFT_OPENAPI_GENERATOR_GIT_TAG)" \
		--depth 1 \
		"$(SWIFT_OPENAPI_GENERATOR_GIT_URL)" \
		$@

$(SWIFT_OPENAPI_GENERATOR_BIN): $(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)
	swift \
		build \
		--package-path "$(SWIFT_OPENAPI_GENERATOR_CLONE_DIR)" \
		--configuration "$(SWIFT_OPENAPI_GENERATOR_BUILD_CONFIGURATION)" \
		--product swift-openapi-generator

$(OPENAPI_YAML_DIRECTORY):
	mkdir -p "$@"

$(OUTPUT_DIRECTORY):
	mkdir -p "$@"

$(SWAGGER_UI_PATH):
	mkdir -p "$@"

$(SWAGGER_UI_JS_PATH): $(SWAGGER_UI_PATH)
	curl -fLs "${SWAGGER_UI_URL}@${SWAGGER_UI_VERSION}/swagger-ui-bundle.min.js" -o "${SWAGGER_UI_JS_PATH}"

$(SWAGGER_UI_CSS_PATH): $(SWAGGER_UI_PATH)
	curl -fLs "${SWAGGER_UI_URL}@${SWAGGER_UI_VERSION}/swagger-ui.min.css" -o "${SWAGGER_UI_CSS_PATH}"

swagger-ui: $(SWAGGER_UI_JS_PATH) $(SWAGGER_UI_CSS_PATH)
