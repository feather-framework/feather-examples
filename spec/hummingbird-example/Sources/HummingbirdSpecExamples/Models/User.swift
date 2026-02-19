import Hummingbird

struct User: ResponseCodable, Equatable {
    let id: String
    let name: String
    let email: String
    let isActive: Bool
}

struct UserCreateRequest: Codable {
    let name: String
    let email: String
    let isActive: Bool?
}

struct UserUpdateRequest: Codable {
    let name: String
    let email: String
    let isActive: Bool?
}

struct UserPatchRequest: Codable {
    let name: String?
    let email: String?
    let isActive: Bool?
}

struct UserCountResponse: ResponseCodable, Equatable {
    let count: Int
}
