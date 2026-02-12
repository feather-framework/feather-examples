import FeatherSpec
import FeatherVaporSpec
import HTTPTypes
import NIOCore
import OpenAPIRuntime
import Testing
import Vapor
import SpecExampleOpenAPI

@testable import VaporSpecExamplesServer

actor Capture<Value: Sendable> {
    private var value: Value?

    func set(_ newValue: Value) {
        value = newValue
    }

    func get() -> Value? {
        value
    }
}

actor TodoCapture {
    private var todo: Components.Schemas.TodoSchema?

    func set(_ value: Components.Schemas.TodoSchema) {
        todo = value
    }

    func value() -> Components.Schemas.TodoSchema {
        guard let todo else {
            preconditionFailure("Todo not set")
        }
        return todo
    }
}

func makeRunner() async throws -> (app: Application, runner: VaporSpecRunner) {
    let app = try await buildApplication(environment: .testing)
    return (app: app, runner: VaporSpecRunner(app: app))
}

func shutdownApp(_ app: Application) async {
    try? await app.asyncShutdown()
}

func runSpec(
    using runner: VaporSpecRunner,
    @SpecBuilder builder: () -> SpecBuilderParameter
) async throws {
    try await runner.run {
        builder()
    }
}

func runSpecJSONReturn<T: Decodable & Sendable>(
    using runner: VaporSpecRunner,
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

func createTodo(
    runner: VaporSpecRunner,
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

func createList(
    runner: VaporSpecRunner,
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
