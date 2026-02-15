# mail-example-openapi

Shared OpenAPI-generated Swift types used by the example servers.

This package is consumed by:
- `smtp-example`
- `ses-example`

## Endpoint
- `POST /mail/send`
- JSON body:
  - `{ "email": "user@example.com" }`
  - `{ "email": null }`

## Build
```bash
swift build
```

## Browser Testing
Run Swagger UI from either example package:
- SMTP UI: `cd ../smtp-example && make run-openapi` (http://127.0.0.1:8889)
- SES UI: `cd ../ses-example && make run-openapi` (http://127.0.0.1:8888)

Then run the matching API server:
- SMTP server: `cd ../smtp-example && make run-server` (http://127.0.0.1:8081)
- SES server: `cd ../ses-example && make run-server` (http://127.0.0.1:8080)
