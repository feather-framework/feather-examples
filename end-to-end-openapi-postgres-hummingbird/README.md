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

- `ExampleServerTestSuite` checks the normal API flow.
- It covers create, get, list, update, patch, delete, and not-found cases.

## Validation tests

Validation rules and request validation extensions are defined in:

- `example-server/Sources/ExampleServer/Validation/ExampleAPIValidation+Rules.swift`
- `example-server/Sources/ExampleServer/Validation/ExampleAPIValidation+Failures.swift`

Validation test coverage is in:

- `example-server/Tests/ExampleServerTests/ExampleServerValidationTestSuite.swift`

## Run tests

```sh
cd example-server
swift test
```

## Notes

- `example-server` tests are end-to-end and require the Postgres environment to be available.
