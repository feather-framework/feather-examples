import ExampleOpenAPI
import FeatherValidation
import FeatherValidationFoundation

// Default rule sets for OpenAPI payloads handled by the example server.
private enum RequestValidators {

    // Validates list names for create/update/patch payloads.
    static func listName(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .trimmedNonempty(),
                .characterSet(.ascii),
                .starts(with: "list-"),
                .ends(with: "-name"),
                .notContains(options: ["list-admin-name", "list-root-name"]),
                .count(min: 2),
                .count(max: 60),
            ]
        )
    }

    // Validates todo names for create/update/patch payloads.
    static func todoName(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .trimmedNonempty(),
                .characterSet(.ascii),
                .starts(with: "task-"),
                .ends(with: "-todo"),
                .notContains(options: ["task-admin-todo", "task-root-todo"]),
                .count(min: 2),
                .count(max: 120),
            ]
        )
    }

    // Validates todo list identifiers.
    static func todoListId(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .trimmedNonempty(),
                .characterSet(.ascii),
                .count(21),
                .count(max: 64),
            ]
        )
    }
}

extension Components.Schemas.ListCreateSchema {
    // Validation rules for list creation payloads.
    static var rules: [ListCreateValidation] {
        [
            { payload in RequestValidators.listName("name", payload.name, required: true) }
        ]
    }
}

extension Components.Schemas.ListUpdateSchema {
    // Validation rules for full list update payloads.
    static var rules: [ListUpdateValidation] {
        [
            { payload in RequestValidators.listName("name", payload.name, required: true) }
        ]
    }
}

extension Components.Schemas.ListPatchSchema {
    // Validation rules for partial list update payloads.
    static var rules: [ListPatchValidation] {
        [
            { payload in RequestValidators.listName("name", payload.name, required: false) }
        ]
    }
}

extension Components.Schemas.TodoCreateSchema {
    // Validation rules for todo creation payloads.
    static var rules: [TodoCreateValidation] {
        [
            { payload in RequestValidators.todoName("name", payload.name, required: true) },
            { payload in RequestValidators.todoListId("listId", payload.listId, required: true) },
        ]
    }
}

extension Components.Schemas.TodoUpdateSchema {
    // Validation rules for full todo update payloads.
    static var rules: [TodoUpdateValidation] {
        [
            { payload in RequestValidators.todoName("name", payload.name, required: true) },
            { payload in RequestValidators.todoListId("listId", payload.listId, required: true) },
        ]
    }
}

extension Components.Schemas.TodoPatchSchema {
    // Validation rules for partial todo update payloads.
    static var rules: [TodoPatchValidation] {
        [
            { payload in RequestValidators.todoName("name", payload.name, required: false) },
            { payload in RequestValidators.todoListId("listId", payload.listId, required: false) },
        ]
    }
}
