import SpecExampleOpenAPI
import FeatherHummingbirdSpec
import FeatherSpec
import HTTPTypes
import NIOCore
import OpenAPIRuntime
import Testing

@testable import HummingbirdSpecExamplesServer

/// Generic capture helper for async expectations.
actor Capture<Value: Sendable> {
    private var value: Value?

    /// Stores a captured value.
    func set(_ newValue: Value) {
        value = newValue
    }

    /// Returns the captured value, if any.
    func get() -> Value? {
        value
    }
}

/// Capture helper for todo payloads.
actor TodoCapture {
    private var todo: Components.Schemas.TodoSchema?

    /// Stores a captured todo.
    func set(_ value: Components.Schemas.TodoSchema) {
        todo = value
    }

    /// Returns the captured todo or fails.
    func value() -> Components.Schemas.TodoSchema {
        guard let todo else {
            preconditionFailure("Todo not set")
        }
        return todo
    }
}

/// Builds a runner backed by the example server application.
func makeRunner() async throws -> HummingbirdSpecRunner {
    let app = try await buildApplication()
    return HummingbirdSpecRunner(app: app)
}

/// Runs a spec against the provided runner.
func runSpec(
    using runner: HummingbirdSpecRunner,
    @SpecBuilder builder: () -> SpecBuilderParameter
) async throws {
    try await runner.run {
        builder()
    }
}

/// Runs a spec and returns the decoded JSON payload.
func runSpecJSONReturn<T: Decodable & Sendable>(
    using runner: HummingbirdSpecRunner,
    @SpecBuilder builder: () -> SpecBuilderParameter
) async throws -> T {
    let capture = Capture<T>()

    try await runSpec(using: runner) {
        builder()
        JSONResponse(
            type: T.self
        ) { value in
            await capture.set(value)
        }
    }

    guard let ret = await capture.get() else {
        preconditionFailure("Expected JSON response payload.")
    }
    return ret
}

/// Runs a spec and returns the raw binary payload.
func runSpecBinaryReturn(
    using runner: HummingbirdSpecRunner,
    @SpecBuilder builder: () -> SpecBuilderParameter
) async throws -> ByteBuffer {
    let capture = Capture<ByteBuffer>()

    try await runSpec(using: runner) {
        builder()
        BinaryResponse { data in
            await capture.set(data)
        }
    }

    guard let ret = await capture.get() else {
        preconditionFailure("Expected binary response payload.")
    }
    return ret
}

/// Runs a spec and returns the raw HTTP response and body.
func runSpecHTTPReturn(
    using runner: HummingbirdSpecRunner,
    @SpecBuilder builder: () -> SpecBuilderParameter
) async throws -> (response: HTTPResponse, body: HTTPBody) {
    let capture = Capture<(HTTPResponse, HTTPBody)>()

    try await runSpec(using: runner) {
        builder()
        Expect { response, body in
            await capture.set((response, body))
        }
    }

    guard let ret = await capture.get() else {
        preconditionFailure("Expected HTTP response payload.")
    }
    return ret
}

/// Creates a todo via the API and returns the response payload.
func createTodo(
    runner: HummingbirdSpecRunner,
    name: String = "task01",
    isCompleted: Bool = false,
    listId: String = "list01"
) async throws -> Components.Schemas.TodoSchema {
    let capture = TodoCapture()
    let payload = Components.Schemas.TodoCreateSchema(
        name: name,
        isCompleted: isCompleted,
        listId: listId
    )
    let body = HTTPBody.json(payload)

    try await runner.run {
        Method(.post)
        Path("todos")
        Header(.contentType, "application/json")
        Body(body)
        Expect(.created)
        Expect { response, body in
            let todo = try await body.decode(
                Components.Schemas.TodoSchema.self,
                with: response
            )
            await capture.set(todo)
        }
    }

    return await capture.value()
}

/// Creates a list via the API and returns the response payload.
func createList(
    runner: HummingbirdSpecRunner,
    name: String = "list01"
) async throws -> Components.Schemas.ListSchema {
    let capture = Capture<Components.Schemas.ListSchema>()
    let payload = Components.Schemas.ListCreateSchema(name: name)

    try await runSpec(using: runner) {
        POST("lists")
        JSONBody(payload)
        JSONResponse(status: .created, type: Components.Schemas.ListSchema.self) { value in
            await capture.set(value)
        }
    }

    guard let ret = await capture.get() else {
        preconditionFailure("List not set")
    }
    return ret
}
