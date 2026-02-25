# End-to-end OpenAPI + Postgres + Hummingbird

This example shows an end-to-end setup built with:

- Feather OpenAPI
- Feather Postgres Database
- Hummingbird
- Swift OpenAPI Generator

## Project layout

- `openapi-example`: shared OpenAPI package (generated Swift types + OpenAPI YAML)
- `backend-example`: Hummingbird server using Postgres
- `http-client-example`: simple API client example

## Notes

- `backend-example` tests are end-to-end and require the Postgres environment to be available.
