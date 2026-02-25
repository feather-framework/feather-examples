// swift-tools-version:6.1
import PackageDescription

// NOTE: https://github.com/swift-server/swift-http-server/blob/main/Package.swift
var defaultSwiftSettings: [SwiftSetting] =
[
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0441-formalize-language-mode-terminology.md
    .swiftLanguageMode(.v6),
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0444-member-import-visibility.md
    .enableUpcomingFeature("MemberImportVisibility"),
    // https://forums.swift.org/t/experimental-support-for-lifetime-dependencies-in-swift-6-2-and-beyond/78638
    .enableExperimentalFeature("Lifetimes"),
    // https://github.com/swiftlang/swift/pull/65218
    .enableExperimentalFeature("AvailabilityMacro=example 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
]

defaultSwiftSettings += [
    .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
]

let package = Package(
    name: "backend-example",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .executable(name: "ExampleServer", targets: ["ExampleServer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/hummingbird-project/hummingbird",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-configuration",
            from: "1.0.0",
            traits: [
                .defaults,
                "CommandLineArguments"
            ]
        ),
        .package(
            url: "https://github.com/hummingbird-project/swift-openapi-hummingbird",
            from: "2.0.1"
        ),
        .package(
            url: "https://github.com/feather-framework/feather-database-postgres",
            exact: "1.0.0-beta.5"
        ),
        .package(
            url: "https://github.com/feather-framework/feather-validation",
            exact: "1.0.0-beta.1"
        ),
        .package(
            url: "https://github.com/BinaryBirds/swift-nanoid",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/feather-framework/feather-spec-hummingbird",
            from: "1.0.0-beta.3"
        ),
        .package(
            url: "https://github.com/feather-framework/feather-spec",
            from: "1.0.0-beta.2"
        ),
        .package(path: "../openapi-example"),
    ],
    targets: [
        .executableTarget(
            name: "ExampleServer",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "NanoID", package: "swift-nanoid"),
                .product(name: "FeatherDatabasePostgres", package: "feather-database-postgres"),
                .product(name: "FeatherValidation", package: "feather-validation"),
                .product(name: "FeatherValidationFoundation", package: "feather-validation"),
                .product(name: "ExampleOpenAPI", package: "openapi-example"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .executableTarget(
            name: "ExampleMigrator",
            dependencies: [
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "FeatherDatabasePostgres", package: "feather-database-postgres"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "ExampleServerTests",
            dependencies: [
                .target(name: "ExampleServer"),
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "ExampleOpenAPI", package: "openapi-example"),
                .product(name: "FeatherSpec", package: "feather-spec"),
                .product(name: "FeatherSpecHummingbird", package: "feather-spec-hummingbird"),
                .product(name: "HummingbirdTesting", package: "hummingbird")
            ],
            swiftSettings: defaultSwiftSettings
        )
    ]
)
