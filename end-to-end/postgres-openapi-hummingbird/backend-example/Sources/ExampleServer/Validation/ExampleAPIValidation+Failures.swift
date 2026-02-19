import ExampleOpenAPI
import FeatherValidation

// Request-specific validation closure aliases for list and todo payloads.
typealias ListCreateValidation = @Sendable (Components.Schemas.ListCreateSchema) -> Validation
typealias ListUpdateValidation = @Sendable (Components.Schemas.ListUpdateSchema) -> Validation
typealias ListPatchValidation = @Sendable (Components.Schemas.ListPatchSchema) -> Validation
typealias TodoCreateValidation = @Sendable (Components.Schemas.TodoCreateSchema) -> Validation
typealias TodoUpdateValidation = @Sendable (Components.Schemas.TodoUpdateSchema) -> Validation
typealias TodoPatchValidation = @Sendable (Components.Schemas.TodoPatchSchema) -> Validation

extension Components.Schemas.ListCreateSchema {
    // Collects validation failures for list create payloads.
    func failures(rules: [ListCreateValidation] = Self.rules) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension Components.Schemas.ListUpdateSchema {
    // Collects validation failures for list update payloads.
    func failures(rules: [ListUpdateValidation] = Self.rules) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension Components.Schemas.ListPatchSchema {
    // Collects validation failures for list patch payloads.
    func failures(rules: [ListPatchValidation] = Self.rules) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension Components.Schemas.TodoCreateSchema {
    // Collects validation failures for todo create payloads.
    func failures(rules: [TodoCreateValidation] = Self.rules) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension Components.Schemas.TodoUpdateSchema {
    // Collects validation failures for todo update payloads.
    func failures(rules: [TodoUpdateValidation] = Self.rules) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension Components.Schemas.TodoPatchSchema {
    // Collects validation failures for todo patch payloads.
    func failures(rules: [TodoPatchValidation] = Self.rules) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

private func validationFailures<Input: Sendable>(
    for payload: Input,
    rules: [@Sendable (Input) -> Validation]
) async -> [Failure] {
    // Builds one validation group from all configured rules.
    let validators = rules.map { $0(payload) }
    return await GroupValidator(validators: validators).failures()
}
