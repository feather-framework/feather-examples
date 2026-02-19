import FeatherSpec
import FeatherSpecVapor
import HTTPTypes
import Vapor

@testable import VaporSpecExamples

enum VaporSpecExamplesTestHelpers {
    static func makeRunner() async throws -> (app: Application, runner: SpecRunnerVapor) {
        let app = try await buildApplication(environment: .testing)
        return (app: app, runner: SpecRunnerVapor(app: app))
    }

    static func shutdownApp(_ app: Application) async {
        try? await app.asyncShutdown()
    }

    static func runSpec(
        using runner: SpecRunnerVapor,
        @SpecBuilder builder: () -> SpecBuilderParameter
    ) async throws {
        try await runner.run { builder() }
    }

    static func runSpecJSONReturn<T: Decodable & Sendable>(
        using runner: SpecRunnerVapor,
        status: HTTPResponse.Status = .ok,
        @SpecBuilder builder: @escaping () -> SpecBuilderParameter
    ) async throws -> T {
        var result: T?
        try await runSpec(using: runner) {
            builder()
            JSONResponse(status: status, type: T.self) { value in
                result = value
            }
        }

        guard let result else {
            throw VaporSpecExamplesHelpersError.missingValue
        }
        return result
    }

    static func createUser(
        runner: SpecRunnerVapor,
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
}

private enum VaporSpecExamplesHelpersError: Error {
    case missingValue
}
