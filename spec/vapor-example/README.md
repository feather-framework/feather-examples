# Vapor spec examples

This package contains a simple Vapor user CRUD example tested with Feather Vapor Spec.

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

Examples:

```sh
# Create
curl -i -X POST http://127.0.0.1:8080/users \
  -H 'content-type: application/json' \
  -d '{"name":"Alex","email":"alex@example.com","isActive":true}'

# List
curl -i http://127.0.0.1:8080/users

# Active users
curl -i http://127.0.0.1:8080/users/active

# Count
curl -i http://127.0.0.1:8080/users/count

# Activate / Deactivate
curl -i -X POST http://127.0.0.1:8080/users/<id>/activate
curl -i -X POST http://127.0.0.1:8080/users/<id>/deactivate
```

## Usage

Run tests:

```sh
cd spec/vapor-example
swift test
```
