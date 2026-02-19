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

## Spec tests

The full Hummingbird spec test suite is in:

- `backend-example/Tests/ExampleServerTests`

- `ExampleServerTestSuite` checks the normal API flow.
- It covers create, get, list, update, patch, delete, and not-found cases.

## Validation tests

Validation rules and request validation extensions are defined in:

- `backend-example/Sources/ExampleServer/Validation/ExampleAPIValidation+Rules.swift`
- `backend-example/Sources/ExampleServer/Validation/ExampleAPIValidation+Failures.swift`

Validation test coverage is in:

- `backend-example/Tests/ExampleServerTests/ExampleServerValidationTestSuite.swift`

## Run tests

```sh
cd backend-example
swift test
```

## Notes

- `backend-example` tests are end-to-end and require the Postgres environment to be available.
