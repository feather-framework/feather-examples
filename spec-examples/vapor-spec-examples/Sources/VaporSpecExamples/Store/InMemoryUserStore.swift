import Foundation

actor InMemoryUserStore {
    private var users: [String: User] = [:]

    func listUsers() -> [User] {
        users.values.sorted { $0.id < $1.id }
    }

    func listActiveUsers() -> [User] {
        users.values
            .filter(\.isActive)
            .sorted { $0.id < $1.id }
    }

    func userCount() -> Int {
        users.count
    }

    func getUser(id: String) -> User? {
        users[id]
    }

    func createUser(name: String, email: String, isActive: Bool) -> User {
        let user = User(
            id: UUID().uuidString,
            name: name,
            email: email,
            isActive: isActive
        )
        users[user.id] = user
        return user
    }

    func updateUser(id: String, name: String, email: String, isActive: Bool) -> User? {
        guard users[id] != nil else {
            return nil
        }
        let user = User(id: id, name: name, email: email, isActive: isActive)
        users[id] = user
        return user
    }

    func patchUser(id: String, name: String?, email: String?, isActive: Bool?) -> User? {
        guard let current = users[id] else {
            return nil
        }
        let user = User(
            id: id,
            name: name ?? current.name,
            email: email ?? current.email,
            isActive: isActive ?? current.isActive
        )
        users[id] = user
        return user
    }

    func setUserActive(id: String, isActive: Bool) -> User? {
        guard let current = users[id] else {
            return nil
        }
        let user = User(
            id: current.id,
            name: current.name,
            email: current.email,
            isActive: isActive
        )
        users[id] = user
        return user
    }

    func deleteUser(id: String) -> Bool {
        users.removeValue(forKey: id) != nil
    }
}
