import FeatherValidation
import FeatherValidationFoundation

private enum ListFieldValidator {
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
                .starts(with: "list-"),
                .ends(with: "-name"),
                .notContains(options: ["list-admin-name", "list-root-name"]),
                .count(min: 2),
                .count(max: 60),
            ]
        )
    }
}

extension Objects.List.Create {
    func validate() async throws(ValidationError) {
        try await GroupValidator {
            ListFieldValidator.name(name, required: true)
        }
        .validate()
    }
}

extension Objects.List.Update {
    func validate() async throws(ValidationError) {
        try await GroupValidator {
            ListFieldValidator.name(name, required: true)
        }
        .validate()
    }
}

extension Objects.List.Patch {
    func validate() async throws(ValidationError) {
        try await GroupValidator {
            ListFieldValidator.name(name, required: false)
        }
        .validate()
    }
}

