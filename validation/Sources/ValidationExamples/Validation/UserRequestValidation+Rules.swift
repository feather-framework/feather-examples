import FeatherValidation
import FeatherValidationFoundation

// Default validation rule lists per request type using feather-validation `Rule` extensions.
private enum RequestValidators {
    // Composes name rules using `Rule+Collection` and `Rule+Contains`.
    static func name(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        GroupValidator {
            Validator(
                key: key,
                value: value,
                required: required,
                rules: [
                    .trimmedNonempty(),
                    .count(min: 2),
                    .count(max: 60),
                    .notContains(options: ["admin", "root"]),
                ]
            )
        }
    }

    // Composes role rules using allow-list matching.
    static func role(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .contains(options: ["member", "editor"])
            ]
        )
    }

    // Composes exact-length invite code rules.
    static func inviteCode(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .count(8)
            ]
        )
    }

    // Composes username format rules using string prefix/suffix/length checks.
    static func username(
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
                .starts(with: "user-"),
                .ends(with: "-id"),
                .length(11),
            ]
        )
    }

    // Composes trust score rules with directional comparable constraints.
    static func trustScore(
        _ key: String,
        _ value: Int?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .greaterThan(0),
                .lessThanOrEqual(100),
            ]
        )
    }

    // Composes login count rules using integer helpers.
    static func loginCount(
        _ key: String,
        _ value: Int?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .nonNegative(),
                .range(0...1000),
            ]
        )
    }

    // Composes email validation rules.
    static func email(
        _ key: String,
        _ value: String?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [.trimmedNonempty(), .email(rule: .regular)]
        )
    }

    // Composes age range rules using `Rule+Comparable`.
    static func age(
        _ key: String,
        _ value: Int?,
        required: Bool
    ) -> Validation {
        Validator(
            key: key,
            value: value,
            required: required,
            rules: [
                .between(18...120)
            ]
        )
    }
}

extension UserCreateRequest {
    // Validation rule set for create payloads.
    static var rules: [UserCreateValidation] {
        [
            { payload in RequestValidators.name("name", payload.name, required: true) },
            { payload in RequestValidators.email("email", payload.email, required: true) },
            { payload in RequestValidators.age("age", payload.age, required: true) },
            { payload in RequestValidators.role("role", payload.role, required: true) },
            { payload in RequestValidators.inviteCode("inviteCode", payload.inviteCode, required: true) },
            { payload in RequestValidators.username("username", payload.username, required: true) },
            { payload in RequestValidators.trustScore("trustScore", payload.trustScore, required: true) },
            { payload in RequestValidators.loginCount("loginCount", payload.loginCount, required: true) },
        ]
    }
}

extension UserUpdateRequest {
    // Validation rule set for full update payloads.
    static var rules: [UserUpdateValidation] {
        [
            { payload in RequestValidators.name("name", payload.name, required: true) },
            { payload in RequestValidators.email("email", payload.email, required: true) },
            { payload in RequestValidators.age("age", payload.age, required: true) },
            { payload in RequestValidators.role("role", payload.role, required: true) },
            { payload in RequestValidators.inviteCode("inviteCode", payload.inviteCode, required: true) },
            { payload in RequestValidators.username("username", payload.username, required: true) },
            { payload in RequestValidators.trustScore("trustScore", payload.trustScore, required: true) },
            { payload in RequestValidators.loginCount("loginCount", payload.loginCount, required: true) },
        ]
    }
}

extension UserPatchRequest {
    // Validation rule set for partial update payloads.
    static var rules: [UserPatchValidation] {
        [
            { payload in RequestValidators.name("name", payload.name, required: false) },
            { payload in RequestValidators.email("email", payload.email, required: false) },
            { payload in RequestValidators.age("age", payload.age, required: false) },
            { payload in RequestValidators.role("role", payload.role, required: false) },
            { payload in RequestValidators.inviteCode("inviteCode", payload.inviteCode, required: false) },
            { payload in RequestValidators.username("username", payload.username, required: false) },
            { payload in RequestValidators.trustScore("trustScore", payload.trustScore, required: false) },
            { payload in RequestValidators.loginCount("loginCount", payload.loginCount, required: false) },
        ]
    }
}
