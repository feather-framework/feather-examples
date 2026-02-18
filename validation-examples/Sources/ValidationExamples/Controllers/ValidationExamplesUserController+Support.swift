import FeatherValidation
import Foundation
import Hummingbird

// Shared controller utilities for path parsing and JSON responses.
extension ValidationExamplesUserController {
    // Extracts the `:id` segment from `/users/:id/...` routes.
    func userId(from request: Request) -> String {
        let segments = request.uri.path.split(separator: "/", omittingEmptySubsequences: true)
        guard segments.count >= 2 else {
            return ""
        }
        return String(segments[1])
    }

    // Encodes validator failures into the API error response schema.
    func validationErrorResponse(failures: [Failure]) throws -> Response {
        let items = failures.map { ValidationErrorItem(key: $0.key, message: $0.message) }
        return try jsonResponse(status: .unprocessableContent, value: ValidationErrorResponse(errors: items))
    }

    // Encodes a single user response with JSON headers.
    func jsonResponse(status: HTTPResponse.Status, user: User) throws -> Response {
        try jsonResponse(status: status, value: user)
    }

    // Encodes a user collection response with JSON headers.
    func jsonResponse(status: HTTPResponse.Status, users: [User]) throws -> Response {
        try jsonResponse(status: status, value: users)
    }

    // Encodes any payload as JSON and applies content headers.
    func jsonResponse<T: Encodable>(status: HTTPResponse.Status, value: T) throws -> Response {
        let data = try JSONEncoder().encode(value)
        let body = ByteBuffer(bytes: data)
        var headers: HTTPFields = [.contentType: "application/json; charset=utf-8"]
        headers[.contentLength] = String(data.count)
        return Response(
            status: status,
            headers: headers,
            body: .init(byteBuffer: body)
        )
    }
}
