import FeatherSpec
import ExampleOpenAPI
import HTTPTypes
import Testing
import Foundation

/// Validation-focused API tests for list and todo payloads.
@Suite
struct ExampleServerValidationTestSuite {
    // Well-formed id that does not exist in the test database.
    private let missingListId = "123456789012345678901"

    /// Rejects todo creation when `name` is empty.
    @Test
    func todoCreateEmptyNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "",
                isCompleted: false,
                listId: missingListId
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo creation when `name` is only whitespace.
    @Test
    func todoCreateWhitespaceNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "   ",
                isCompleted: false,
                listId: missingListId
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo creation when `listId` is empty.
    @Test
    func todoCreateEmptyListIdReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task-01-todo",
                isCompleted: false,
                listId: ""
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo creation when `listId` is not an exact 21-character id.
    @Test
    func todoCreateInvalidListIdLengthReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task-01-todo",
                isCompleted: false,
                listId: "123"
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo creation when list reference is well-formed but missing.
    @Test
    func todoCreateMissingListReferenceReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task-01-todo",
                isCompleted: false,
                listId: missingListId
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo update when `name` is empty.
    @Test
    func todoUpdateEmptyNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
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
    }

    /// Rejects todo patch when `name` is empty.
    @Test
    func todoPatchEmptyNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

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

    /// Rejects todo patch when provided `listId` is only whitespace.
    @Test
    func todoPatchWhitespaceListIdReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)
        let created = try await createTodo(runner: runner, listId: list.id)

        try await runSpec(using: runner) {
            PATCH("todos/\(created.id)")
            JSONBody(Components.Schemas.TodoPatchSchema(
                name: nil,
                isCompleted: nil,
                listId: "  "
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo creation when name uses disallowed reserved values.
    @Test
    func todoCreateReservedNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task-admin-todo",
                isCompleted: false,
                listId: list.id
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects todo creation when name contains non-ASCII characters.
    @Test
    func todoCreateNonASCIINameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task-ä-todo",
                isCompleted: false,
                listId: list.id
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects duplicate todo names within the same list.
    @Test
    func todoCreateDuplicateNameInListReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
        let list = try await createList(runner: runner)
        _ = try await createTodo(runner: runner, name: "task-dup-todo", listId: list.id)

        try await runSpec(using: runner) {
            POST("todos")
            JSONBody(Components.Schemas.TodoCreateSchema(
                name: "task-dup-todo",
                isCompleted: false,
                listId: list.id
            ))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects list creation when `name` is empty.
    @Test
    func listCreateEmptyNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: ""))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects list creation when `name` is only whitespace.
    @Test
    func listCreateWhitespaceNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: "  "))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects list creation when name does not match prefix/suffix rules.
    @Test
    func listCreateInvalidPrefixSuffixReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: "alpha"))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects list creation when name uses disallowed reserved values.
    @Test
    func listCreateReservedNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: "list-admin-name"))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects list creation when name contains non-ASCII characters.
    @Test
    func listCreateNonASCIINameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: "list-ä-name"))
            Expect(.unprocessableContent)
        }
    }

    /// Rejects duplicate list names.
    @Test
    func listCreateDuplicateNameReturnsUnprocessable() async throws {
        let runner = try await makeRunner()
        let token = UUID().uuidString.prefix(8).lowercased()
        let name = "list-\(token)-dup-name"
        _ = try await createList(runner: runner, name: name)

        try await runSpec(using: runner) {
            POST("lists")
            JSONBody(Components.Schemas.ListCreateSchema(name: name))
            Expect(.unprocessableContent)
        }
    }

    /// Normalizes repeated/extra spaces in list names before persistence.
    @Test
    func listCreateNormalizesWhitespaceBeforePersistence() async throws {
        let runner = try await makeRunner()
        let token = UUID().uuidString.prefix(8).lowercased()
        let rawName = "  list-\(token)   space-name  "

        let created = try await createList(runner: runner, name: rawName)

        #expect(created.name == "list-\(token) space-name")
    }

    /// Validates payload before persistence lookup for list update.
    @Test
    func listUpdateInvalidPayloadReturnsUnprocessable() async throws {
        let runner = try await makeRunner()

        try await runSpec(using: runner) {
            PUT("lists/missing")
            JSONBody(Components.Schemas.ListUpdateSchema(name: ""))
            Expect(.unprocessableContent)
        }
    }
}
