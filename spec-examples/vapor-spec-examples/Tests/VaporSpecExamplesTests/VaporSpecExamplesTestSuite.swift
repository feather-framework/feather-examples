import FeatherSpec
import HTTPTypes
import OpenAPIRuntime
import Testing
import SpecExampleOpenAPI

@Suite
struct VaporSpecExamplesTestSuite {

    @Test
    func testCreateGetAndListTodos() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        let fetched: Components.Schemas.TodoSchema = try await runSpecJSONReturn(using: runner) {
            GET("todos/\(created.id)")
            Expect(.ok)
        }

        #expect(fetched.id == created.id)
        #expect(fetched.name == created.name)

        let todos: [Components.Schemas.TodoSchema] = try await runSpecJSONReturn(using: runner) {
            GET("todos")
            Expect(.ok)
        }

        #expect(todos.contains { $0.id == created.id })
    }

    @Test
    func testUpdateAndPatchTodo() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        let updatePayload = Components.Schemas.TodoUpdateSchema(
            name: "task02",
            isCompleted: true,
            listId: list.id
        )

        let updated: Components.Schemas.TodoSchema = try await runSpecJSONReturn(using: runner) {
            PUT("todos/\(created.id)")
            JSONBody(updatePayload)
            JSONResponse(type: Components.Schemas.TodoSchema.self) { value in
                #expect(value.name == "task02")
                #expect(value.isCompleted == true)
                #expect(value.listId == list.id)
            }
        }

        #expect(updated.name == "task02")
        #expect(updated.isCompleted == true)
        #expect(updated.listId == list.id)

        let patchPayload = Components.Schemas.TodoPatchSchema(name: "task03")

        let patched: Components.Schemas.TodoSchema = try await runSpecJSONReturn(using: runner) {
            PATCH("todos/\(created.id)")
            JSONBody(patchPayload)
            Expect(.ok)
        }

        #expect(patched.name == "task03")
        #expect(patched.listId == list.id)
    }

    @Test
    func testDeleteTodo() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        try await runSpec(using: runner) {
            DELETE("todos/\(created.id)")
            Expect(.noContent)
        }

        try await runSpec(using: runner) {
            GET("todos/\(created.id)")
            Expect(.notFound)
        }
    }

    @Test
    func testTodoNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            GET("todos/missing")
            Expect(.notFound)
        }

        try await runSpec(using: runner) {
            DELETE("todos/missing")
            Expect(.notFound)
        }
    }

    @Test
    func testTodoValidation() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "",
                isCompleted: false,
                listId: "list01"
            ))
            Expect(.unprocessableContent)
        }

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task01",
                isCompleted: false,
                listId: ""
            ))
            Expect(.unprocessableContent)
        }

        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        try await runSpec(using: runner) {
            PUT("todos/\(created.id)")
            JSONBody(Components.Schemas.TodoUpdateSchema(
                name: "",
                isCompleted: false,
                listId: list.id
            ))
            Expect(.unprocessableContent)
        }

        try await runSpec(using: runner) {
            PATCH("todos/\(created.id)")
            JSONBody(Components.Schemas.TodoPatchSchema(
                name: "",
                isCompleted: nil,
                listId: nil
            ))
            Expect(.unprocessableContent)
        }
    }

    @Test
    func testCreateGetAndListLists() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createList(runner: runner, name: "list-alpha")

        let fetched: Components.Schemas.ListSchema = try await runSpecJSONReturn(using: runner) {
            GET("lists/\(created.id)")
            Expect(.ok)
        }

        #expect(fetched.id == created.id)
        #expect(fetched.name == created.name)

        let lists: [Components.Schemas.ListSchema] = try await runSpecJSONReturn(using: runner) {
            GET("lists")
            Expect(.ok)
        }

        #expect(lists.contains { $0.id == created.id })
    }

    @Test
    func testUpdateAndPatchList() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createList(runner: runner, name: "list-alpha")

        let updatePayload = Components.Schemas.ListUpdateSchema(name: "list-beta")
        let updated: Components.Schemas.ListSchema = try await runSpecJSONReturn(using: runner) {
            PUT("lists/\(created.id)")
            JSONBody(updatePayload)
            Expect(.ok)
        }

        #expect(updated.name == "list-beta")

        let patchPayload = Components.Schemas.ListPatchSchema(name: "list-gamma")
        let patched: Components.Schemas.ListSchema = try await runSpecJSONReturn(using: runner) {
            PATCH("lists/\(created.id)")
            JSONBody(patchPayload)
            Expect(.ok)
        }

        #expect(patched.name == "list-gamma")
    }

    @Test
    func testDeleteList() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createList(runner: runner, name: "list-alpha")

        try await runSpec(using: runner) {
            DELETE("lists/\(created.id)")
            Expect(.noContent)
        }

        try await runSpec(using: runner) {
            GET("lists/\(created.id)")
            Expect(.notFound)
        }
    }

    @Test
    func testListNotFoundAndValidation() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            GET("lists/missing")
            Expect(.notFound)
        }

        try await runSpec(using: runner) {
            DELETE("lists/missing")
            Expect(.notFound)
        }

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: ""))
            Expect(.unprocessableContent)
        }

        try await runSpec(using: runner) {
            PUT("lists/missing")
            JSONBody(Components.Schemas.ListUpdateSchema(name: ""))
            Expect(.unprocessableContent)
        }
    }
}
