import FeatherSpec
import HTTPTypes
import ExampleOpenAPI
import OpenAPIRuntime
import Testing
import Foundation

/// Spec-driven tests for the Hummingbird examples server API.
@Suite
struct ExampleServerTestSuite {

    /// Covers list and get behaviors for todos.
    @Test
    func testCreateGetAndListTodos() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        // Fetch the created item by id.
        let fetched: Components.Schemas.TodoSchema = try await runSpecJSONReturn(using: runner) {
            GET("todos/\(created.id)")
            Expect(.ok)
        }

        // Validate data integrity.
        #expect(fetched.id == created.id)
        #expect(fetched.name == created.name)

        // Fetch all todos.
        let todos: [Components.Schemas.TodoSchema] = try await runSpecJSONReturn(using: runner) {
            GET("todos")
            Expect(.ok)
        }

        #expect(todos.contains { $0.id == created.id })
    }

    /// Covers update and patch paths for todos.
    @Test
    func testUpdateAndPatchTodo() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        // Full update payload.
        let updatePayload = Components.Schemas.TodoUpdateSchema(
            name: "task-02-todo",
            isCompleted: true,
            listId: list.id
        )

        // Apply PUT update and assert values.
        let updated: Components.Schemas.TodoSchema = try await runSpecJSONReturn(using: runner) {
            PUT("todos/\(created.id)")
            JSONBody(updatePayload)
            JSONResponse(type: Components.Schemas.TodoSchema.self) { value in
                #expect(value.name == "task-02-todo")
                #expect(value.isCompleted == true)
                #expect(value.listId == list.id)
            }
        }

        #expect(updated.name == "task-02-todo")
        #expect(updated.isCompleted == true)
        #expect(updated.listId == list.id)

        // Partial update payload.
        let patchPayload = Components.Schemas.TodoPatchSchema(name: "task-03-todo")

        // Apply PATCH update and validate.
        let patched: Components.Schemas.TodoSchema = try await runSpecJSONReturn(using: runner) {
            PATCH("todos/\(created.id)")
            JSONBody(patchPayload)
            Expect(.ok)
        }

        #expect(patched.name == "task-03-todo")
        #expect(patched.listId == list.id)
    }

    /// Covers delete and post-delete fetch for todos.
    @Test
    func testDeleteTodo() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        // Delete the record.
        try await runSpec(using: runner) {
            DELETE("todos/\(created.id)")
            Expect(.noContent)
        }

        // Ensure it no longer exists.
        try await runSpec(using: runner) {
            GET("todos/\(created.id)")
            Expect(.notFound)
        }
    }

    /// Covers missing todo responses.
    @Test
    func testTodoNotFound() async throws {
        let runner = try await makeRunner()
        try await runSpec(using: runner) {
            GET("todos/missing")
            Expect(.notFound)
        }

        try await runSpec(using: runner) {
            DELETE("todos/missing")
            Expect(.noContent)
        }
    }

    /// Covers list and get behaviors for lists.
    @Test
    func testCreateGetAndListLists() async throws {
        let runner = try await makeRunner()
        let created = try await createList(runner: runner)

        // Fetch the created list by id.
        let fetched: Components.Schemas.ListSchema = try await runSpecJSONReturn(using: runner) {
            GET("lists/\(created.id)")
            Expect(.ok)
        }

        // Validate data integrity.
        #expect(fetched.id == created.id)
        #expect(fetched.name == created.name)

        // Fetch all lists.
        let lists: [Components.Schemas.ListSchema] = try await runSpecJSONReturn(using: runner) {
            GET("lists")
            Expect(.ok)
        }

        #expect(lists.contains { $0.id == created.id })
    }

    /// Covers update and patch paths for lists.
    @Test
    func testUpdateAndPatchList() async throws {
        let runner = try await makeRunner()
        let created = try await createList(runner: runner)

        // Full update payload.
        let token = created.id.prefix(6).lowercased()
        let updatePayload = Components.Schemas.ListUpdateSchema(name: "list-\(token)-beta-name")
        let updated: Components.Schemas.ListSchema = try await runSpecJSONReturn(using: runner) {
            PUT("lists/\(created.id)")
            JSONBody(updatePayload)
            Expect(.ok)
        }

        // Verify update response.
        #expect(updated.name == "list-\(token)-beta-name")

        // Partial update payload.
        let patchPayload = Components.Schemas.ListPatchSchema(name: "list-\(token)-gamma-name")
        let patched: Components.Schemas.ListSchema = try await runSpecJSONReturn(using: runner) {
            PATCH("lists/\(created.id)")
            JSONBody(patchPayload)
            Expect(.ok)
        }

        // Verify patch response.
        #expect(patched.name == "list-\(token)-gamma-name")
    }

    /// Covers delete and post-delete fetch for lists.
    @Test
    func testDeleteList() async throws {
        let runner = try await makeRunner()
        let created = try await createList(runner: runner)

        // Delete the record.
        try await runSpec(using: runner) {
            DELETE("lists/\(created.id)")
            Expect(.noContent)
        }

        // Ensure it no longer exists.
        try await runSpec(using: runner) {
            GET("lists/\(created.id)")
            Expect(.notFound)
        }
    }

    /// Covers missing list responses.
    @Test
    func testListNotFound() async throws {
        let runner = try await makeRunner()

        // Missing list by id.
        try await runSpec(using: runner) {
            GET("lists/missing")
            Expect(.notFound)
        }

        // Missing list deletion is idempotent in this implementation.
        try await runSpec(using: runner) {
            DELETE("lists/missing")
            Expect(.noContent)
        }
    }
}
