# End-to-end OpenAPI + Postgres + Hummingbird

This example shows an end-to-end setup built with:

- Feather OpenAPI
- Feather Postgres Database
- Hummingbird
- Swift OpenAPI Generator

## Project layout

- `example-openapi`: shared OpenAPI package (generated Swift types + OpenAPI YAML)
- `example-server`: Hummingbird server using Postgres
- `example-client`: simple API client example

## Spec tests

The full Hummingbird spec test suite is in:

- `example-server/Tests/ExampleServerTests`

Run tests:

```sh
cd example-server
swift test
```

## Notes

- `example-server` tests are end-to-end and require the Postgres environment to be available.
