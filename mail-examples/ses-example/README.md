# ses-example

Hummingbird server example that sends mail through AWS SES using `FeatherSESMail`.

## Config
Create `config.yml` in this directory:

```yml
SES_ID: ""
SES_SECRET: ""
SES_REGION: "us-west-1"
SES_FROM: ""
SES_TO: ""
```

Notes:
- `SES_REGION`, `SES_FROM`, and `SES_TO` are required.
- `SES_ID` and `SES_SECRET` are optional, but must be set together.
- If incoming `email` is null/empty/invalid, `SES_TO` is used as fallback recipient.

## Run
```bash
swift run SESExample
```
or with Makefile:
```bash
make run-server
```

## Browser Testing
Mail sending is testable from the OpenAPI browser UI when both are running:
- SES Swagger UI (`make run-openapi` in this directory Makefile, then open `http://127.0.0.1:8888`)
- `ses-example` server (`make run-server` in this directory Makefile, serves `http://127.0.0.1:8080`)

## API
`POST /mail/send`

Request body:
- `{"email":"user@example.com"}`
- `{"email":null}`

Examples:

```bash
curl -i -X POST http://127.0.0.1:8080/mail/send \
  -H 'content-type: application/json' \
  -d '{"email":null}'
```

```bash
curl -i -X POST http://127.0.0.1:8080/mail/send \
  -H 'content-type: application/json' \
  -d '{"email":"user@example.com"}'
```

## Test
```bash
swift test
```

Tests run the server and send requests over HTTP.  
For tests, mail delivery uses `FeatherMemoryMail` (no real SES call).
