import FeatherSpec
import FeatherVaporSpec
import HTTPTypes
import Testing
import Vapor

@testable import VaporSpecExamples

actor Capture<Value: Sendable> {
    private var value: Value?

    func set(_ newValue: Value) {
        value = newValue
    }

    func get() -> Value? {
        value
    }
}

@Suite
struct VaporSpecExamplesTestSuite {

    func makeRunner() async throws -> (app: Application, runner: VaporSpecRunner) {
        let app = try await buildApplication(environment: .testing)
        return (app: app, runner: VaporSpecRunner(app: app))
    }

    func shutdownApp(_ app: Application) async {
        try? await app.asyncShutdown()
    }

    func runSpec(
        using runner: VaporSpecRunner,
        @SpecBuilder builder: () -> SpecBuilderParameter
    ) async throws {
        try await runner.run { builder() }
    }

    func runSpecJSONReturn<T: Decodable & Sendable>(
        using runner: VaporSpecRunner,
        status: HTTPResponse.Status = .ok,
        @SpecBuilder builder: () -> SpecBuilderParameter
    ) async throws -> T {
        let capture = Capture<T>()

        try await runSpec(using: runner) {
            builder()
            JSONResponse(status: status, type: T.self) { value in
                await capture.set(value)
            }
        }

        guard let ret = await capture.get() else {
            Issue.record("Expected JSON response payload")
            throw TestError.missingValue
        }
        return ret
    }

    func createUser(
        runner: VaporSpecRunner,
        name: String = "Alex",
        email: String = "alex@example.com",
        isActive: Bool = true
    ) async throws -> User {
        try await runSpecJSONReturn(using: runner, status: .created) {
            POST("users")
            JSONBody(UserCreateRequest(name: name, email: email, isActive: isActive))
            Expect(.created)
        }
    }

    @Test
    func createUserReturnsExpectedName() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let user = try await createUser(runner: runner)
        #expect(user.name == "Alex")
    }

    @Test
    func createUserReturnsExpectedEmail() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let user = try await createUser(runner: runner)
        #expect(user.email == "alex@example.com")
    }

    @Test
    func createUserReturnsActiveByDefault() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let user = try await createUser(runner: runner)
        #expect(user.isActive == true)
    }

    @Test
    func getUserByIdReturnsMatchingId() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let fetched: User = try await runSpecJSONReturn(using: runner) {
            GET("users/\(created.id)")
            Expect(.ok)
        }
        #expect(fetched.id == created.id)
    }

    @Test
    func listUsersIncludesCreatedUser() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let users: [User] = try await runSpecJSONReturn(using: runner) {
            GET("users")
            Expect(.ok)
        }
        #expect(users.contains { $0.id == created.id })
    }

    @Test
    func getUserReturnsJsonContentType() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        try await runSpec(using: runner) {
            GET("users/\(created.id)")
            Expect(.ok)
            Expect(.contentType) { value in
                #expect(value.contains("application/json"))
            }
        }
    }

    @Test
    func updateUserChangesName() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let updated: User = try await runSpecJSONReturn(using: runner) {
            PUT("users/\(created.id)")
            JSONBody(UserUpdateRequest(name: "Alex Cooper", email: "alex.cooper@example.com", isActive: false))
            Expect(.ok)
        }
        #expect(updated.name == "Alex Cooper")
    }

    @Test
    func updateUserChangesEmail() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let updated: User = try await runSpecJSONReturn(using: runner) {
            PUT("users/\(created.id)")
            JSONBody(UserUpdateRequest(name: "Alex Cooper", email: "alex.cooper@example.com", isActive: false))
            Expect(.ok)
        }
        #expect(updated.email == "alex.cooper@example.com")
    }

    @Test
    func updateUserChangesIsActive() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let updated: User = try await runSpecJSONReturn(using: runner) {
            PUT("users/\(created.id)")
            JSONBody(UserUpdateRequest(name: "Alex Cooper", email: "alex.cooper@example.com", isActive: false))
            Expect(.ok)
        }
        #expect(updated.isActive == false)
    }

    @Test
    func patchUserChangesName() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let patched: User = try await runSpecJSONReturn(using: runner) {
            PATCH("users/\(created.id)")
            JSONBody(UserPatchRequest(name: "Alex C.", email: nil, isActive: nil))
            Expect(.ok)
        }
        #expect(patched.name == "Alex C.")
    }

    @Test
    func patchUserKeepsEmailWhenOmitted() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        let patched: User = try await runSpecJSONReturn(using: runner) {
            PATCH("users/\(created.id)")
            JSONBody(UserPatchRequest(name: "Alex C.", email: nil, isActive: nil))
            Expect(.ok)
        }
        #expect(patched.email == "alex@example.com")
    }

    @Test
    func deleteUserReturnsNoContent() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)

        try await runSpec(using: runner) {
            DELETE("users/\(created.id)")
            Expect(.noContent)
        }
    }

    @Test
    func deletedUserIsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)

        try await runSpec(using: runner) {
            DELETE("users/\(created.id)")
            Expect(.noContent)
        }

        try await runSpec(using: runner) {
            GET("users/\(created.id)")
            Expect(.notFound)
        }
    }

    @Test
    func createUserInvalidPayloadReturnsUnprocessable() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            POST("users")
            JSONBody(UserCreateRequest(name: "", email: "invalid", isActive: nil))
            Expect(.unprocessableContent)
        }
    }

    @Test
    func updateUserInvalidPayloadReturnsUnprocessable() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner)
        try await runSpec(using: runner) {
            PUT("users/\(created.id)")
            JSONBody(UserUpdateRequest(name: "", email: "x", isActive: nil))
            Expect(.unprocessableContent)
        }
    }

    @Test
    func patchUserInvalidPayloadReturnsUnprocessable() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(runner: runner, name: "Ben", email: "ben@example.com")
        try await runSpec(using: runner) {
            PATCH("users/\(created.id)")
            JSONBody(UserPatchRequest(name: nil, email: "", isActive: nil))
            Expect(.unprocessableContent)
        }
    }

    @Test
    func listActiveUsersIncludesActiveUser() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let active = try await createUser(
            runner: runner,
            name: "Active User",
            email: "active@example.com",
            isActive: true
        )
        _ = try await createUser(
            runner: runner,
            name: "Inactive User",
            email: "inactive@example.com",
            isActive: false
        )

        let users: [User] = try await runSpecJSONReturn(using: runner) {
            GET("users/active")
            Expect(.ok)
        }
        #expect(users.contains { $0.id == active.id })
    }

    @Test
    func listActiveUsersExcludesInactiveUsers() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        _ = try await createUser(
            runner: runner,
            name: "Active User",
            email: "active@example.com",
            isActive: true
        )
        let inactive = try await createUser(
            runner: runner,
            name: "Inactive User",
            email: "inactive@example.com",
            isActive: false
        )

        let users: [User] = try await runSpecJSONReturn(using: runner) {
            GET("users/active")
            Expect(.ok)
        }
        #expect(!users.contains { $0.id == inactive.id })
    }

    @Test
    func userCountReturnsCurrentUserCount() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        _ = try await createUser(runner: runner, name: "User One", email: "one@example.com")
        _ = try await createUser(runner: runner, name: "User Two", email: "two@example.com")

        let payload: UserCountResponse = try await runSpecJSONReturn(using: runner) {
            GET("users/count")
            Expect(.ok)
        }
        #expect(payload.count == 2)
    }

    @Test
    func userCountIsZeroAfterDeletingAllUsers() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let first = try await createUser(runner: runner, name: "User One", email: "one@example.com")
        let second = try await createUser(runner: runner, name: "User Two", email: "two@example.com")

        try await runSpec(using: runner) {
            DELETE("users/\(first.id)")
            Expect(.noContent)
        }

        try await runSpec(using: runner) {
            DELETE("users/\(second.id)")
            Expect(.noContent)
        }

        let payload: UserCountResponse = try await runSpecJSONReturn(using: runner) {
            GET("users/count")
            Expect(.ok)
        }
        #expect(payload.count == 0)
    }

    @Test
    func activateUserSetsIsActiveTrue() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(
            runner: runner,
            name: "Dormant User",
            email: "dormant@example.com",
            isActive: false
        )

        let user: User = try await runSpecJSONReturn(using: runner) {
            POST("users/\(created.id)/activate")
            Expect(.ok)
        }
        #expect(user.isActive == true)
    }

    @Test
    func deactivateUserSetsIsActiveFalse() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        let created = try await createUser(
            runner: runner,
            name: "Enabled User",
            email: "enabled@example.com",
            isActive: true
        )

        let user: User = try await runSpecJSONReturn(using: runner) {
            POST("users/\(created.id)/deactivate")
            Expect(.ok)
        }
        #expect(user.isActive == false)
    }

    @Test
    func missingGetUserReturnsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            GET("users/missing")
            Expect(.notFound)
        }
    }

    @Test
    func missingPutUserReturnsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            PUT("users/missing")
            JSONBody(UserUpdateRequest(name: "Name", email: "name@example.com", isActive: true))
            Expect(.notFound)
        }
    }

    @Test
    func missingPatchUserReturnsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            PATCH("users/missing")
            JSONBody(UserPatchRequest(name: "New", email: nil, isActive: nil))
            Expect(.notFound)
        }
    }

    @Test
    func missingDeleteUserReturnsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            DELETE("users/missing")
            Expect(.notFound)
        }
    }

    @Test
    func missingActivateUserReturnsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            POST("users/missing/activate")
            Expect(.notFound)
        }
    }

    @Test
    func missingDeactivateUserReturnsNotFound() async throws {
        let (app, runner) = try await makeRunner()
        defer { Task { await shutdownApp(app) } }

        try await runSpec(using: runner) {
            POST("users/missing/deactivate")
            Expect(.notFound)
        }
    }
}

private enum TestError: Error {
    case missingValue
}
