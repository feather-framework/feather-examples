import FeatherValidation
import FeatherValidationFoundation

private enum TodoFieldValidator {
    static func name(
        _ value: String?,
        required: Bool
    ) -> Validator<String> {
        .init(
            key: "name",
            value: value,
            required: required,
            invocation: .all,
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

    static func listId(
        _ value: String?,
        required: Bool
    ) -> Validator<String> {
        .init(
            key: "listId",
            value: value,
            required: required,
            invocation: .all,
            rules: [
                .trimmedNonempty(),
                .characterSet(.ascii),
                .count(21),
                .count(max: 64),
            ]
        )
    }
}

extension Objects.Todo.Create {
    func validate() async throws(ValidationError) {
        try await GroupValidator {
            TodoFieldValidator.name(name, required: true)
            TodoFieldValidator.listId(listId.rawValue, required: true)
        }
        .validate()
    }
}

extension Objects.Todo.Update {
    func validate() async throws(ValidationError) {
        try await GroupValidator {
            TodoFieldValidator.name(name, required: true)
            TodoFieldValidator.listId(listId.rawValue, required: true)
        }
        .validate()
    }
}

extension Objects.Todo.Patch {
    func validate() async throws(ValidationError) {
        try await GroupValidator {
            TodoFieldValidator.name(name, required: false)
            TodoFieldValidator.listId(listId?.rawValue, required: false)
        }
        .validate()
    }
}

