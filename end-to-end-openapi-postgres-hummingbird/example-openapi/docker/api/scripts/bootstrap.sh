#!/bin/bash
set -e

SWAGGER_UI_URL="https://cdn.jsdelivr.net/npm/swagger-ui-dist"
SWAGGER_UI_VERSION="5.31.0"
SWAGGER_UI_DIR="swagger-ui"

WWW_DIR="docker/api/www"

pushd ${WWW_DIR}

if [ -e "${SWAGGER_UI_DIR}" ]; then rm -r "${SWAGGER_UI_DIR}" ; fi
mkdir -p "${SWAGGER_UI_DIR}"

curl -fLs "${SWAGGER_UI_URL}@${SWAGGER_UI_VERSION}/swagger-ui.min.css" -o "${SWAGGER_UI_DIR}/swagger-ui.min.css"
curl -fLs "${SWAGGER_UI_URL}@${SWAGGER_UI_VERSION}/swagger-ui-bundle.min.js" -o "${SWAGGER_UI_DIR}/swagger-ui-bundle.min.js"

popd
