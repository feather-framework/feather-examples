import Hummingbird
import HummingbirdTesting
import Testing

@testable import ValidationExamples

// End-to-end route tests covering positive and negative user API scenarios.
@Suite
struct ValidationExamplesTestSuite {
    
    @Test
    // Returns an empty list when no users have been created.
    func listUsersInitiallyReturnsEmptyArray() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users", method: .get)
            #expect(response.status == .ok)
            let users = try ValidationExamplesTestHelpers.decode([User].self, from: response.body)
            #expect(users.isEmpty)
        }
    }

    @Test
    // Includes newly created users in the `/users` response.
    func listUsersContainsCreatedUsers() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let first = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Alex", email: "alex@example.com")
        let second = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Bela", email: "bela@example.com")

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users", method: .get)
            #expect(response.status == .ok)
            let users = try ValidationExamplesTestHelpers.decode([User].self, from: response.body)
            #expect(users.contains(where: { $0.id == first.id }))
            #expect(users.contains(where: { $0.id == second.id }))
        }
    }

    @Test
    // Filters inactive users out of the `/users/active` response.
    func listActiveUsersExcludesInactiveUsers() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        _ = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Alex", email: "alex@example.com", isActive: true)
        let inactive = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Bela", email: "bela@example.com", isActive: false)

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/active", method: .get)
            #expect(response.status == .ok)
            let users = try ValidationExamplesTestHelpers.decode([User].self, from: response.body)
            #expect(users.allSatisfy { $0.isActive })
            #expect(users.contains(where: { $0.id == inactive.id }) == false)
        }
    }

    @Test
    // Starts the count endpoint at zero in a fresh app instance.
    func userCountInitiallyReturnsZero() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/count", method: .get)
            #expect(response.status == .ok)
            let count = try ValidationExamplesTestHelpers.decode(UserCountResponse.self, from: response.body)
            #expect(count.count == 0)
        }
    }

    @Test
    // Increments the count endpoint after user creation.
    func userCountReflectsCreatedUsers() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        _ = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Alex", email: "alex@example.com")
        _ = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Bela", email: "bela@example.com")

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/count", method: .get)
            #expect(response.status == .ok)
            let count = try ValidationExamplesTestHelpers.decode(UserCountResponse.self, from: response.body)
            #expect(count.count == 2)
        }
    }

    @Test
    // Returns persisted user data for an existing id.
    func getUserExistingReturnsExpectedUser() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Alex", email: "alex@example.com")

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/\(created.id)", method: .get)
            #expect(response.status == .ok)
            let user = try ValidationExamplesTestHelpers.decode(User.self, from: response.body)
            #expect(user.id == created.id)
            #expect(user.name == "Alex")
        }
    }

    @Test
    // Returns 404 when fetching a missing user id.
    func getUserMissingReturnsNotFound() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/missing", method: .get)
            #expect(response.status == .notFound)
        }
    }

    @Test
    // Accepts a valid create payload and returns 201.
    func createUserValidPayloadReturnsCreated() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "alex@example.com", age: 32, isActive: true)
                )
            )
            #expect(response.status == .created)
            let user = try ValidationExamplesTestHelpers.decode(User.self, from: response.body)
            #expect(user.role == "member")
            #expect(user.inviteCode == "AB12CD34")
            #expect(user.username == "user-alx-id")
            #expect(user.trustScore == 50)
            #expect(user.loginCount == 0)
        }
    }

    @Test
    // Rejects create requests when `role` is outside the allowed options.
    func createUserInvalidRoleReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(role: "owner")
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["role"])
        }
    }

    @Test
    // Rejects create requests when invite codes do not match exact length.
    func createUserInvalidInviteCodeLengthReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(inviteCode: "SHORT")
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["inviteCode"])
        }
    }

    @Test
    // Rejects create requests when trust score is not greater than zero.
    func createUserTrustScoreAtLowerBoundaryReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(trustScore: 0)
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["trustScore"])
        }
    }

    @Test
    // Rejects create requests when trust score exceeds the configured maximum.
    func createUserTrustScoreAboveMaximumReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(trustScore: 101)
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["trustScore"])
        }
    }

    @Test
    // Rejects create requests when usernames miss the required prefix.
    func createUserUsernameMissingPrefixReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(username: "acct-alx-id")
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["username"])
        }
    }

    @Test
    // Rejects create requests when usernames miss the required suffix.
    func createUserUsernameMissingSuffixReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(username: "user-alx-xx")
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["username"])
        }
    }

    @Test
    // Rejects create requests when usernames do not match required length.
    func createUserUsernameInvalidLengthReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(username: "user-id")
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["username"])
        }
    }

    @Test
    // Rejects create requests when login count is negative.
    func createUserNegativeLoginCountReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(loginCount: -1)
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(response, keys: ["loginCount"])
        }
    }

    @Test
    // Rejects create requests where `name` is missing.
    func createUserMissingNameReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: nil, email: "alex@example.com", age: 32, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Rejects create requests where `email` is missing.
    func createUserMissingEmailReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: nil, age: 32, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Rejects create requests where `age` is missing.
    func createUserMissingAgeReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "alex@example.com", age: nil, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Rejects create requests with an invalid email format.
    func createUserInvalidEmailReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "invalid", age: 32, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Enforces the minimum name length rule on create.
    func createUserNameTooShortReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "A", email: "alex@example.com", age: 32, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Rejects reserved names blocked by `notContains` rules.
    func createUserReservedNameReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "admin", email: "alex@example.com", age: 32, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Accepts the lower name-length boundary.
    func createUserNameMinBoundaryPasses() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Al", email: "alex@example.com", age: 32, isActive: nil)
                )
            )
            #expect(response.status == .created)
        }
    }

    @Test
    // Rejects ages below the allowed range.
    func createUserAgeBelowRangeReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "alex@example.com", age: 17, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Accepts the minimum allowed age value.
    func createUserAgeLowerBoundaryPasses() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "alex@example.com", age: 18, isActive: nil)
                )
            )
            #expect(response.status == .created)
        }
    }

    @Test
    // Accepts the maximum allowed age value.
    func createUserAgeUpperBoundaryPasses() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "alex@example.com", age: 120, isActive: nil)
                )
            )
            #expect(response.status == .created)
        }
    }

    @Test
    // Rejects ages above the allowed range.
    func createUserAgeAboveRangeReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "Alex", email: "alex@example.com", age: 121, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Returns validation errors for all failing fields in one response.
    func createUserReturnsAllErrorKeys() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: "", email: "invalid", age: 200, isActive: nil)
                )
            )
            try ValidationExamplesTestHelpers.expectValidationErrorKeys(
                response,
                keys: ["name", "email", "age"]
            )
        }
    }

    @Test
    // Returns 400 for malformed JSON request bodies.
    func createUserMalformedJsonReturnsBadRequest() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let malformed = ByteBufferAllocator().buffer(string: "{\"name\":\"Alex\",")
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: malformed
            )
            #expect(response.status == .badRequest)
        }
    }

    @Test
    // Requires all mandatory fields for full update requests.
    func updateUserRequiresAllFields() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(app: app)

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users/\(created.id)",
                method: .put,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserUpdateRequest(name: "Alex", email: nil, age: 32, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Returns 404 when updating a missing user id.
    func updateUserMissingReturnsNotFound() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users/missing",
                method: .put,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserUpdateRequest(name: "Alex", email: "alex@example.com", age: 32, isActive: true)
                )
            )
            #expect(response.status == .notFound)
        }
    }

    @Test
    // Allows patch requests that omit optional fields.
    func patchUserOmitsFieldsAndStillSucceeds() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(app: app)

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users/\(created.id)",
                method: .patch,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserPatchRequest(name: nil, email: nil, age: nil, isActive: nil)
                )
            )
            #expect(response.status == .ok)
        }
    }

    @Test
    // Validates email format on patch when provided.
    func patchUserInvalidEmailReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(app: app)

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users/\(created.id)",
                method: .patch,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserPatchRequest(name: nil, email: "bad", age: nil, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Validates age range on patch when provided.
    func patchUserInvalidAgeReturnsUnprocessable() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(app: app)

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users/\(created.id)",
                method: .patch,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserPatchRequest(name: nil, email: nil, age: 999, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
        }
    }

    @Test
    // Returns 404 when patching a missing user id.
    func patchUserMissingReturnsNotFound() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users/missing",
                method: .patch,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserPatchRequest(name: "Alex", email: nil, age: nil, isActive: nil)
                )
            )
            #expect(response.status == .notFound)
        }
    }

    @Test
    // Sets `isActive` to true through the activate endpoint.
    func activateUserSetsIsActiveTrue() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(
            app: app,
            name: "Alex",
            email: "alex@example.com",
            isActive: false
        )

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/\(created.id)/activate", method: .post)
            #expect(response.status == .ok)
            let user = try ValidationExamplesTestHelpers.decode(User.self, from: response.body)
            #expect(user.isActive)
        }
    }

    @Test
    // Sets `isActive` to false through the deactivate endpoint.
    func deactivateUserSetsIsActiveFalse() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(
            app: app,
            name: "Alex",
            email: "alex@example.com",
            isActive: true
        )

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/\(created.id)/deactivate", method: .post)
            #expect(response.status == .ok)
            let user = try ValidationExamplesTestHelpers.decode(User.self, from: response.body)
            #expect(user.isActive == false)
        }
    }

    @Test
    // Returns 404 when activating a missing user id.
    func activateUserMissingReturnsNotFound() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/missing/activate", method: .post)
            #expect(response.status == .notFound)
        }
    }

    @Test
    // Returns 404 when deactivating a missing user id.
    func deactivateUserMissingReturnsNotFound() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/missing/deactivate", method: .post)
            #expect(response.status == .notFound)
        }
    }

    @Test
    // Removes a user and confirms it is no longer retrievable.
    func deleteUserRemovesUser() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()
        let created = try await ValidationExamplesTestHelpers.createUser(app: app, name: "Alex", email: "alex@example.com")

        try await app.test(.router) { client in
            let deleted = try await client.execute(uri: "/users/\(created.id)", method: .delete)
            #expect(deleted.status == .noContent)

            let fetch = try await client.execute(uri: "/users/\(created.id)", method: .get)
            #expect(fetch.status == .notFound)
        }
    }

    @Test
    // Returns 404 when deleting a missing user id.
    func deleteUserMissingReturnsNotFound() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(uri: "/users/missing", method: .delete)
            #expect(response.status == .notFound)
        }
    }

    @Test
    // Returns JSON content type headers for validation errors.
    func validationErrorsReturnJsonContentType() async throws {
        let app = try await ValidationExamplesTestHelpers.makeApp()

        try await app.test(.router) { client in
            let response = try await client.execute(
                uri: "/users",
                method: .post,
                headers: [.contentType: "application/json"],
                body: try ValidationExamplesTestHelpers.jsonBuffer(
                    UserCreateRequest(name: nil, email: nil, age: nil, isActive: nil)
                )
            )
            #expect(response.status == .unprocessableContent)
            #expect(response.headers[.contentType]?.contains("application/json") == true)
        }
    }
}
