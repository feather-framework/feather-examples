# mail-example-openapi

OpenAPI-first package for a minimal mail API example.

## Endpoint
- `POST /mail/send`
- JSON body: `{ "email": "user@example.com" }`
- `email` can also be `null`

## Regenerate OpenAPI Swift files
```bash
swift-openapi-generator generate openapi/openapi.yaml \
  --config openapi-generator-config.yaml \
  --output-directory Sources/MailExampleOpenAPI
```
