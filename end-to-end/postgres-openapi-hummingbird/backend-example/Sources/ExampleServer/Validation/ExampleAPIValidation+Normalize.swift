import ExampleOpenAPI
import Foundation

// Normalization helpers applied before validation and persistence.
private func normalizedText(_ value: String) -> String {
    value.split(whereSeparator: \.isWhitespace).joined(separator: " ")
}

private func normalizedIdentifier(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines)
}

extension Components.Schemas.ListCreateSchema {
    // Returns a list-create payload with normalized name spacing.
    func normalized() -> Self {
        .init(name: normalizedText(name))
    }
}

extension Components.Schemas.ListUpdateSchema {
    // Returns a list-update payload with normalized name spacing.
    func normalized() -> Self {
        .init(name: normalizedText(name))
    }
}

extension Components.Schemas.ListPatchSchema {
    // Returns a list-patch payload with normalized optional name spacing.
    func normalized() -> Self {
        .init(name: name.map(normalizedText))
    }
}

extension Components.Schemas.TodoCreateSchema {
    // Returns a todo-create payload with normalized name and list-id values.
    func normalized() -> Self {
        .init(
            name: normalizedText(name),
            isCompleted: isCompleted,
            listId: normalizedIdentifier(listId)
        )
    }
}

extension Components.Schemas.TodoUpdateSchema {
    // Returns a todo-update payload with normalized name and list-id values.
    func normalized() -> Self {
        .init(
            name: normalizedText(name),
            isCompleted: isCompleted,
            listId: normalizedIdentifier(listId)
        )
    }
}

extension Components.Schemas.TodoPatchSchema {
    // Returns a todo-patch payload with normalized optional fields.
    func normalized() -> Self {
        .init(
            name: name.map(normalizedText),
            isCompleted: isCompleted,
            listId: listId.map(normalizedIdentifier)
        )
    }
}
