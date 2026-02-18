# Validation examples

This package contains a Hummingbird user CRUD example validated with `feather-validation` (`main`).

Routes:

- `GET /users`
- `GET /users/active`
- `GET /users/count`
- `POST /users`
- `GET /users/:id`
- `PUT /users/:id`
- `PATCH /users/:id`
- `DELETE /users/:id`
- `POST /users/:id/activate`
- `POST /users/:id/deactivate`

Request payload fields (`POST /users`, `PUT /users/:id`, `PATCH /users/:id`):

- `name`
- `email`
- `age`
- `role`
- `inviteCode`
- `username`
- `trustScore`
- `loginCount`
- `isActive`

Validation rules:

- `name`: trimmed non-empty, min/max count, forbidden values (`admin`, `root`)
- `email`: trimmed non-empty, valid email
- `age`: `between(18...120)`
- `role`: allow-list (`member`, `editor`)
- `inviteCode`: exact count `8`
- `username`: starts with `user-`, ends with `-id`, exact length `11`
- `trustScore`: `> 0` and `<= 100`
- `loginCount`: non-negative and in range `0...1000`
- create/update require all fields above (except `isActive` defaults to `true`)
- patch validates only provided fields

Rule families exercised through API tests:

- `Rule+Collection` (`count(min:)`, `count(max:)`, `count(_:)`)
- `Rule+Comparable` (`between`, `greaterThan`, `lessThanOrEqual`)
- `Rule+Contains` (`contains`, `notContains`)
- `Rule+String` (`trimmedNonempty`, `starts`, `ends`, `length`)
- `Rule+Int` (`range`, `nonNegative`)

Extending validations:

- validations are defined in `Sources/ValidationExamples/Validation/UserRequestValidation+Failures.swift` and `Sources/ValidationExamples/Validation/UserRequestValidation+Rules.swift`
- controller uses request validation extensions directly
- add rules by passing custom rule arrays into `payload.failures(rules:)`:

```swift
let extraCreateRule: UserCreateValidation = { payload in
    Validator(key: "name", value: payload.name, rules: [.starts(with: "A")])
}

let failures = await payload.failures(
    rules: UserCreateRequest.rules + [extraCreateRule]
)
```

Model layout:

- `Sources/ValidationExamples/Models/User.swift`
- `Sources/ValidationExamples/Models/UserRequests.swift`
- `Sources/ValidationExamples/Models/UserResponses.swift`

Examples:

```sh
# Create valid user
curl -i -X POST http://127.0.0.1:8080/users \
  -H 'content-type: application/json' \
  -d '{"name":"Alex","email":"alex@example.com","age":32,"role":"member","inviteCode":"AB12CD34","username":"user-alx-id","trustScore":50,"loginCount":0,"isActive":true}'

# Create invalid user (returns 422 + validation errors)
curl -i -X POST http://127.0.0.1:8080/users \
  -H 'content-type: application/json' \
  -d '{"name":"","email":"invalid","age":200,"role":"owner","inviteCode":"BAD","username":"acct-alx","trustScore":0,"loginCount":-1}'

# Create with malformed JSON (returns 400)
curl -i -X POST http://127.0.0.1:8080/users \
  -H 'content-type: application/json' \
  -d '{"name":"Alex",'
```

## Usage

Run tests:

```sh
cd validation-examples
swift test
```
