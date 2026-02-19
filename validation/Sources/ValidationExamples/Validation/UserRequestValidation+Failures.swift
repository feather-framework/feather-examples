import FeatherValidation

// Request extensions that execute validation rule sets and return collected failures.
// Type-erased validation function for create payloads.
typealias UserCreateValidation = @Sendable (UserCreateRequest) -> Validation
// Type-erased validation function for full update payloads.
typealias UserUpdateValidation = @Sendable (UserUpdateRequest) -> Validation
// Type-erased validation function for patch payloads.
typealias UserPatchValidation = @Sendable (UserPatchRequest) -> Validation

extension UserCreateRequest {
    // Collects validation failures for create payload rules.
    func failures(
        rules: [UserCreateValidation] = Self.rules
    ) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension UserUpdateRequest {
    // Collects validation failures for update payload rules.
    func failures(
        rules: [UserUpdateValidation] = Self.rules
    ) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

extension UserPatchRequest {
    // Collects validation failures for patch payload rules.
    func failures(
        rules: [UserPatchValidation] = Self.rules
    ) async -> [Failure] {
        await validationFailures(for: self, rules: rules)
    }
}

private func validationFailures<Input>(
    for payload: Input,
    rules: [@Sendable (Input) -> Validation]
) async -> [Failure] {
    // Builds a single validation group from request-scoped validators.
    let validators = rules.map { $0(payload) }
    return await GroupValidator(validators: validators).failures()
}
