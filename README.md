# Feather Examples

This repository contains Swift example projects organized by use case, so each area can be explored independently while still reflecting real application workflows.

## Directory Structure

```text
feather-examples/
├── end-to-end/
│   └── postgres-openapi-hummingbird/
│       ├── http-client-example/
│       ├── openapi-example/
│       └── backend-example/
├── mail/
│   ├── ses-example/
│   └── smtp-example/
├── spec/
│   ├── hummingbird-example/
│   └── vapor-example/
└── validation/
```

## Folder Descriptions

- `end-to-end`: complete workflow examples that demonstrate API design, server-side implementation, and client-side usage together in one scenario.
- `end-to-end/postgres-openapi-hummingbird`: grouped end-to-end scenario focused on Postgres-backed APIs with OpenAPI and Hummingbird.
- `end-to-end/postgres-openapi-hummingbird/http-client-example`: client integration example for calling the API from a Swift HTTP client.
- `end-to-end/postgres-openapi-hummingbird/openapi-example`: OpenAPI contract package used as the shared interface between services and clients.
- `end-to-end/postgres-openapi-hummingbird/backend-example`: backend service example with runtime server and migration tooling.
- `mail`: messaging-focused examples showing how to integrate application-level email delivery through different providers and transport approaches.
- `mail/ses-example`: provider-based mail delivery example using AWS SES.
- `mail/smtp-example`: SMTP transport-based mail delivery example.
- `spec`: examples centered on contract/spec-driven development and testing patterns across multiple server frameworks.
- `spec/hummingbird-example`: spec-oriented example built on Hummingbird.
- `spec/vapor-example`: spec-oriented example built on Vapor.
- `validation`: focused examples for input validation, request/response rule enforcement, and predictable error handling behavior.
