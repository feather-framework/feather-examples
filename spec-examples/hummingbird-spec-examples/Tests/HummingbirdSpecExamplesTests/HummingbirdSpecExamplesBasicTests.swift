import Testing
import FeatherSpec
import HTTPTypes

@testable import HummingbirdSpecExamples

@Suite
struct HummingbirdSpecExamplesBasicTests {
    @Test
    func createUserReturnsExpectedName() async throws {
        let (app, _) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let user = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        #expect(user.name == "Alex")
    }

    @Test
    func createUserReturnsExpectedEmail() async throws {
        let (app, _) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let user = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        #expect(user.email == "alex@example.com")
    }

    @Test
    func createUserReturnsActiveByDefault() async throws {
        let (app, _) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let user = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        #expect(user.isActive == true)
    }

    @Test
    func getUserByIdReturnsMatchingId() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)

        try await runner.run {
            Method(.get)
            Path("users/\(created.id)")
            Expect(.ok)
            Expect { response, body in
                let fetched = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: body, response: response)
                #expect(fetched.id == created.id)
            }
        }
    }

    @Test
    func listUsersIncludesCreatedUser() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)

        try await runner.run {
            Method(.get)
            Path("users")
            Expect(.ok)
            Expect { response, body in
                let users = try await HummingbirdSpecExamplesTestHelpers.decode([User].self, body: body, response: response)
                #expect(users.contains { $0.id == created.id })
            }
        }
    }

    @Test
    func getUserReturnsJsonContentType() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)

        try await runner.run {
            Method(.get)
            Path("users/\(created.id)")
            Expect(.ok)
            Expect(.contentType) { value in
                #expect(value.contains("application/json"))
            }
        }
    }

    @Test
    func updateUserChangesName() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserUpdateRequest(name: "Alex Cooper", email: "alex.cooper@example.com", isActive: false)
        )

        try await runner.run {
            Method(.put)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, responseBody in
                let updated = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: responseBody, response: response)
                #expect(updated.name == "Alex Cooper")
            }
        }
    }

    @Test
    func updateUserChangesEmail() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserUpdateRequest(name: "Alex Cooper", email: "alex.cooper@example.com", isActive: false)
        )

        try await runner.run {
            Method(.put)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, responseBody in
                let updated = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: responseBody, response: response)
                #expect(updated.email == "alex.cooper@example.com")
            }
        }
    }

    @Test
    func updateUserChangesIsActive() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserUpdateRequest(name: "Alex Cooper", email: "alex.cooper@example.com", isActive: false)
        )

        try await runner.run {
            Method(.put)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, responseBody in
                let updated = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: responseBody, response: response)
                #expect(updated.isActive == false)
            }
        }
    }

    @Test
    func patchUserChangesName() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserPatchRequest(name: "Alex C.", email: nil, isActive: nil)
        )

        try await runner.run {
            Method(.patch)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, responseBody in
                let patched = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: responseBody, response: response)
                #expect(patched.name == "Alex C.")
            }
        }
    }

    @Test
    func patchUserKeepsEmailWhenOmitted() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserPatchRequest(name: "Alex C.", email: nil, isActive: nil)
        )

        try await runner.run {
            Method(.patch)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, responseBody in
                let patched = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: responseBody, response: response)
                #expect(patched.email == "alex@example.com")
            }
        }
    }

    @Test
    func deleteUserReturnsNoContent() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)

        try await runner.run {
            Method(.delete)
            Path("users/\(created.id)")
            Expect(.noContent)
        }
    }

    @Test
    func deletedUserIsNotFound() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)

        try await runner.run {
            Method(.delete)
            Path("users/\(created.id)")
            Expect(.noContent)
        }

        try await runner.run {
            Method(.get)
            Path("users/\(created.id)")
            Expect(.notFound)
        }
    }

    @Test
    func createUserInvalidPayloadReturnsUnprocessable() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserCreateRequest(name: "", email: "invalid", isActive: nil)
        )

        try await runner.run {
            Method(.post)
            Path("users")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.unprocessableContent)
        }
    }

    @Test
    func updateUserInvalidPayloadReturnsUnprocessable() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app)
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserUpdateRequest(name: "", email: "x", isActive: nil)
        )

        try await runner.run {
            Method(.put)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.unprocessableContent)
        }
    }

    @Test
    func patchUserInvalidPayloadReturnsUnprocessable() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app, name: "Ben", email: "ben@example.com")
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserPatchRequest(name: nil, email: "", isActive: nil)
        )

        try await runner.run {
            Method(.patch)
            Path("users/\(created.id)")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.unprocessableContent)
        }
    }

    @Test
    func listActiveUsersIncludesActiveUser() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let active = try await HummingbirdSpecExamplesTestHelpers.createUser(
            app: app,
            name: "Active User",
            email: "active@example.com",
            isActive: true
        )
        _ = try await HummingbirdSpecExamplesTestHelpers.createUser(
            app: app,
            name: "Inactive User",
            email: "inactive@example.com",
            isActive: false
        )

        try await runner.run {
            Method(.get)
            Path("users/active")
            Expect(.ok)
            Expect { response, body in
                let users = try await HummingbirdSpecExamplesTestHelpers.decode([User].self, body: body, response: response)
                #expect(users.contains { $0.id == active.id })
            }
        }
    }

    @Test
    func listActiveUsersExcludesInactiveUsers() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        _ = try await HummingbirdSpecExamplesTestHelpers.createUser(
            app: app,
            name: "Active User",
            email: "active@example.com",
            isActive: true
        )
        let inactive = try await HummingbirdSpecExamplesTestHelpers.createUser(
            app: app,
            name: "Inactive User",
            email: "inactive@example.com",
            isActive: false
        )

        try await runner.run {
            Method(.get)
            Path("users/active")
            Expect(.ok)
            Expect { response, body in
                let users = try await HummingbirdSpecExamplesTestHelpers.decode([User].self, body: body, response: response)
                #expect(!users.contains { $0.id == inactive.id })
            }
        }
    }

    @Test
    func userCountReturnsCurrentUserCount() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        _ = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app, name: "User One", email: "one@example.com")
        _ = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app, name: "User Two", email: "two@example.com")

        try await runner.run {
            Method(.get)
            Path("users/count")
            Expect(.ok)
            Expect { response, body in
                let payload = try await HummingbirdSpecExamplesTestHelpers.decode(UserCountResponse.self, body: body, response: response)
                #expect(payload.count == 2)
            }
        }
    }

    @Test
    func userCountIsZeroAfterDeletingAllUsers() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let first = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app, name: "User One", email: "one@example.com")
        let second = try await HummingbirdSpecExamplesTestHelpers.createUser(app: app, name: "User Two", email: "two@example.com")

        try await runner.run {
            Method(.delete)
            Path("users/\(first.id)")
            Expect(.noContent)
        }

        try await runner.run {
            Method(.delete)
            Path("users/\(second.id)")
            Expect(.noContent)
        }

        try await runner.run {
            Method(.get)
            Path("users/count")
            Expect(.ok)
            Expect { response, body in
                let payload = try await HummingbirdSpecExamplesTestHelpers.decode(UserCountResponse.self, body: body, response: response)
                #expect(payload.count == 0)
            }
        }
    }

    @Test
    func activateUserSetsIsActiveTrue() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(
            app: app,
            name: "Dormant User",
            email: "dormant@example.com",
            isActive: false
        )

        try await runner.run {
            Method(.post)
            Path("users/\(created.id)/activate")
            Expect(.ok)
            Expect { response, body in
                let user = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: body, response: response)
                #expect(user.isActive == true)
            }
        }
    }

    @Test
    func deactivateUserSetsIsActiveFalse() async throws {
        let (app, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let created = try await HummingbirdSpecExamplesTestHelpers.createUser(
            app: app,
            name: "Enabled User",
            email: "enabled@example.com",
            isActive: true
        )

        try await runner.run {
            Method(.post)
            Path("users/\(created.id)/deactivate")
            Expect(.ok)
            Expect { response, body in
                let user = try await HummingbirdSpecExamplesTestHelpers.decode(User.self, body: body, response: response)
                #expect(user.isActive == false)
            }
        }
    }

    @Test
    func missingGetUserReturnsNotFound() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        try await runner.run {
            Method(.get)
            Path("users/missing")
            Expect(.notFound)
        }
    }

    @Test
    func missingPutUserReturnsNotFound() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserUpdateRequest(name: "Name", email: "name@example.com", isActive: true)
        )
        try await runner.run {
            Method(.put)
            Path("users/missing")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.notFound)
        }
    }

    @Test
    func missingPatchUserReturnsNotFound() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        let body = try HummingbirdSpecExamplesTestHelpers.jsonBody(
            UserPatchRequest(name: "New", email: nil, isActive: nil)
        )
        try await runner.run {
            Method(.patch)
            Path("users/missing")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.notFound)
        }
    }

    @Test
    func missingDeleteUserReturnsNotFound() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        try await runner.run {
            Method(.delete)
            Path("users/missing")
            Expect(.notFound)
        }
    }

    @Test
    func missingActivateUserReturnsNotFound() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        try await runner.run {
            Method(.post)
            Path("users/missing/activate")
            Expect(.notFound)
        }
    }

    @Test
    func missingDeactivateUserReturnsNotFound() async throws {
        let (_, runner) = try await HummingbirdSpecExamplesTestHelpers.makeAppAndRunner()
        try await runner.run {
            Method(.post)
            Path("users/missing/deactivate")
            Expect(.notFound)
        }
    }
}
