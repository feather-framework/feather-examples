# smtp-example

Hummingbird server example that sends mail through SMTP using `FeatherSMTPMail`.

## Config
Create `config.yml` in this directory:

```yml
SMTP_HOST: ""
SMTP_USER: ""
SMTP_PASS: ""
SMTP_FROM: ""
SMTP_TO: ""
```

Required keys:
- `SMTP_HOST`
- `SMTP_USER`
- `SMTP_PASS`
- `SMTP_FROM`
- `SMTP_TO`

Notes:
- SMTP port and security are fixed in code to `587` and `STARTTLS`.
- If incoming `email` is null/empty/invalid, `SMTP_TO` is used as fallback recipient.

## Run
```bash
swift run SMTPExample
```
or with Makefile:
```bash
make run-server
```

## Browser Testing
Mail sending is testable from the OpenAPI browser UI when both are running:
- SMTP Swagger UI (`make run-openapi` in this directory Makefile, then open `http://127.0.0.1:8889`)
- `smtp-example` server (`make run-server` in this directory Makefile, serves `http://127.0.0.1:8081`)

If you open `openapi/index.html` directly as a file, pass `?spec=http://127.0.0.1:8889/openapi.yaml`.

## API
`POST /mail/send`

Request body:
- `{"email":"user@example.com"}`
- `{"email":null}`

Examples:

```bash
curl -i -X POST http://127.0.0.1:8081/mail/send \
  -H 'content-type: application/json' \
  -d '{"email":null}'
```

```bash
curl -i -X POST http://127.0.0.1:8081/mail/send \
  -H 'content-type: application/json' \
  -d '{"email":"user@example.com"}'
```

## Test
```bash
swift test
```

Tests run the server and send requests over HTTP.  
For tests, mail delivery uses `FeatherMemoryMail` (no real SMTP delivery).
