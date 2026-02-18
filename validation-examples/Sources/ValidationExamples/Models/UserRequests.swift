// Request body for `POST /users`.
struct UserCreateRequest: Codable {
    let name: String?
    let email: String?
    let age: Int?
    let role: String?
    let inviteCode: String?
    let username: String?
    let trustScore: Int?
    let loginCount: Int?
    let isActive: Bool?

    // Builds create payloads with defaults that satisfy all validation rules.
    init(
        name: String? = "Alex",
        email: String? = "alex@example.com",
        age: Int? = 32,
        role: String? = "member",
        inviteCode: String? = "AB12CD34",
        username: String? = "user-alx-id",
        trustScore: Int? = 50,
        loginCount: Int? = 0,
        isActive: Bool? = true
    ) {
        self.name = name
        self.email = email
        self.age = age
        self.role = role
        self.inviteCode = inviteCode
        self.username = username
        self.trustScore = trustScore
        self.loginCount = loginCount
        self.isActive = isActive
    }
}

// Request body for `PUT /users/:id`.
struct UserUpdateRequest: Codable {
    let name: String?
    let email: String?
    let age: Int?
    let role: String?
    let inviteCode: String?
    let username: String?
    let trustScore: Int?
    let loginCount: Int?
    let isActive: Bool?

    // Builds update payloads with defaults that satisfy all validation rules.
    init(
        name: String? = "Alex",
        email: String? = "alex@example.com",
        age: Int? = 32,
        role: String? = "member",
        inviteCode: String? = "AB12CD34",
        username: String? = "user-alx-id",
        trustScore: Int? = 50,
        loginCount: Int? = 0,
        isActive: Bool? = true
    ) {
        self.name = name
        self.email = email
        self.age = age
        self.role = role
        self.inviteCode = inviteCode
        self.username = username
        self.trustScore = trustScore
        self.loginCount = loginCount
        self.isActive = isActive
    }
}

// Request body for `PATCH /users/:id`.
struct UserPatchRequest: Codable {
    let name: String?
    let email: String?
    let age: Int?
    let role: String?
    let inviteCode: String?
    let username: String?
    let trustScore: Int?
    let loginCount: Int?
    let isActive: Bool?

    // Builds patch payloads where every field is optional by default.
    init(
        name: String? = nil,
        email: String? = nil,
        age: Int? = nil,
        role: String? = nil,
        inviteCode: String? = nil,
        username: String? = nil,
        trustScore: Int? = nil,
        loginCount: Int? = nil,
        isActive: Bool? = nil
    ) {
        self.name = name
        self.email = email
        self.age = age
        self.role = role
        self.inviteCode = inviteCode
        self.username = username
        self.trustScore = trustScore
        self.loginCount = loginCount
        self.isActive = isActive
    }
}
