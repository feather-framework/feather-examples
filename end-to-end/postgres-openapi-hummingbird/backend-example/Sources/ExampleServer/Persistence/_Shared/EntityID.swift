struct EntityID<T>: Hashable, Codable, Sendable {
    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }

    func map<U>(to type: U.Type) -> EntityID<U> {
        .init(rawValue: rawValue)
    }

    func mapObject<U>(to type: U.Type) -> ObjectID<U> {
        .init(rawValue: rawValue)
    }
}
