#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"

echo "== health =="
curl -sS -i "${BASE_URL}/health"
echo

echo "== upload =="
printf 'hello from file-streaming-backend\n' \
| curl -sS -i \
  -X PUT "${BASE_URL}/upload" \
  -H "Content-Type: application/octet-stream" \
  --data-binary @-
echo

echo "== download =="
curl -sS -i "${BASE_URL}/download" -o /tmp/file-streaming-download.bin
echo "Downloaded bytes: $(wc -c < /tmp/file-streaming-download.bin)"
echo "Downloaded content:"
cat /tmp/file-streaming-download.bin
echo
