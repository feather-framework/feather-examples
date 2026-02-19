import Hummingbird

// Root controller type shared by read/write/support extensions.
struct ValidationExamplesUserController {
    // Backing persistence used by all handlers.
    let store: InMemoryUserStore
}
