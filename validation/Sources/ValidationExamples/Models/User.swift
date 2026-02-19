import Hummingbird

// Persisted user representation returned by read and write endpoints.
struct User: ResponseCodable, Equatable {
    let id: String
    let name: String
    let email: String
    let age: Int
    let role: String
    let inviteCode: String
    let username: String
    let trustScore: Int
    let loginCount: Int
    let isActive: Bool
}
