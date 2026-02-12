# smtp-example

Hummingbird server example that uses `MailExampleOpenAPI` and a mail sender abstraction.

## Config
Use `config.yml` with these keys:
- `SMTP_HOST`
- `SMTP_USER`
- `SMTP_PASS`
- `SMTP_FROM`
- `SMTP_TO`

## Run
```bash
swift run SMTPExample
```

## Example request
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
