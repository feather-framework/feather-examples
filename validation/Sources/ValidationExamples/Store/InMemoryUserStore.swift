import Foundation

// Actor-isolated in-memory persistence for test/demo use.
actor InMemoryUserStore {
    private var users: [String: User] = [:]

    // Returns all users sorted by id for deterministic API responses.
    func listUsers() -> [User] {
        users.values.sorted { $0.id < $1.id }
    }

    // Returns only users currently marked as active.
    func listActiveUsers() -> [User] {
        listUsers().filter(\.isActive)
    }

    // Returns the current number of persisted users.
    func userCount() -> Int {
        users.count
    }

    // Creates and stores a new user with a generated identifier.
    func createUser(
        name: String,
        email: String,
        age: Int,
        role: String,
        inviteCode: String,
        username: String,
        trustScore: Int,
        loginCount: Int,
        isActive: Bool
    ) -> User {
        let id = UUID().uuidString.lowercased()
        let user = User(
            id: id,
            name: name,
            email: email,
            age: age,
            role: role,
            inviteCode: inviteCode,
            username: username,
            trustScore: trustScore,
            loginCount: loginCount,
            isActive: isActive
        )
        users[id] = user
        return user
    }

    // Fetches a single user by id.
    func getUser(id: String) -> User? {
        users[id]
    }

    // Replaces an existing user record with a full new payload.
    func updateUser(
        id: String,
        name: String,
        email: String,
        age: Int,
        role: String,
        inviteCode: String,
        username: String,
        trustScore: Int,
        loginCount: Int,
        isActive: Bool
    ) -> User? {
        guard users[id] != nil else {
            return nil
        }
        let user = User(
            id: id,
            name: name,
            email: email,
            age: age,
            role: role,
            inviteCode: inviteCode,
            username: username,
            trustScore: trustScore,
            loginCount: loginCount,
            isActive: isActive
        )
        users[id] = user
        return user
    }

    // Applies partial field updates to an existing user.
    func patchUser(
        id: String,
        name: String?,
        email: String?,
        age: Int?,
        role: String?,
        inviteCode: String?,
        username: String?,
        trustScore: Int?,
        loginCount: Int?,
        isActive: Bool?
    ) -> User? {
        guard let current = users[id] else {
            return nil
        }
        let user = User(
            id: id,
            name: name ?? current.name,
            email: email ?? current.email,
            age: age ?? current.age,
            role: role ?? current.role,
            inviteCode: inviteCode ?? current.inviteCode,
            username: username ?? current.username,
            trustScore: trustScore ?? current.trustScore,
            loginCount: loginCount ?? current.loginCount,
            isActive: isActive ?? current.isActive
        )
        users[id] = user
        return user
    }

    // Deletes a user and reports whether a record existed.
    func deleteUser(id: String) -> Bool {
        users.removeValue(forKey: id) != nil
    }

    // Toggles the active flag while preserving all other fields.
    func setUserActive(id: String, isActive: Bool) -> User? {
        guard let current = users[id] else {
            return nil
        }
        let user = User(
            id: id,
            name: current.name,
            email: current.email,
            age: current.age,
            role: current.role,
            inviteCode: current.inviteCode,
            username: current.username,
            trustScore: current.trustScore,
            loginCount: current.loginCount,
            isActive: isActive
        )
        users[id] = user
        return user
    }
}
