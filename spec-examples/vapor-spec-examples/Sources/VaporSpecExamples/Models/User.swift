import Vapor

struct User: Content, Equatable {
    let id: String
    let name: String
    let email: String
    let isActive: Bool
}

struct UserCreateRequest: Content {
    let name: String
    let email: String
    let isActive: Bool?
}

struct UserUpdateRequest: Content {
    let name: String
    let email: String
    let isActive: Bool?
}

struct UserPatchRequest: Content {
    let name: String?
    let email: String?
    let isActive: Bool?
}

struct UserCountResponse: Content, Equatable {
    let count: Int
}
