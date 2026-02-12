# ses-example

Hummingbird server example that uses `MailExampleOpenAPI` and a mail sender abstraction.

## Run
```bash
swift run SESExample
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
