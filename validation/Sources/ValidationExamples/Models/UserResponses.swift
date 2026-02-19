import Hummingbird

// Response payload for `GET /users/count`.
struct UserCountResponse: ResponseCodable, Equatable {
    let count: Int
}

// Single validation error item with a field key and message.
struct ValidationErrorItem: Codable, Equatable {
    let key: String
    let message: String
}

// Envelope used for 422 validation responses.
struct ValidationErrorResponse: ResponseCodable, Equatable {
    let errors: [ValidationErrorItem]
}
