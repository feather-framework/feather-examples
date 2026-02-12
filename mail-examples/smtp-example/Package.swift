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
    .enableExperimentalFeature("AvailabilityMacro=smtpExample 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
]

#if compiler(>=6.2)
defaultSwiftSettings.append(
    // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
)
#endif

defaultSwiftSettings += [
    .enableExperimentalFeature("StrictConcurrency=complete"),
    .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
]

let package = Package(
    name: "smtp-example",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .executable(name: "SMTPExample", targets: ["SMTPExample"]),
    ],
    dependencies: [
        .package(path: "../mail-example-openapi"),
        .package(url: "https://github.com/hummingbird-project/hummingbird", from: "2.0.0"),
        .package(url: "https://github.com/hummingbird-project/swift-openapi-hummingbird", from: "2.0.1"),
        .package(url: "https://github.com/feather-framework/feather-smtp-mail", exact: "1.0.0-beta.3"),
        .package(url: "https://github.com/feather-framework/feather-memory-mail", from: "1.0.0-beta.1"),
        .package(url: "https://github.com/BinaryBirds/swift-nio-smtp", .upToNextMinor(from: "1.0.0-beta.1")),
        .package(url: "https://github.com/apple/swift-nio", from: "2.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "6.2.1"),
        .package(
            url: "https://github.com/apple/swift-configuration",
            from: "1.0.0",
            traits: [
                .defaults,
                "CommandLineArguments",
                "YAML",
            ]
        ),
    ],
    targets: [
        .executableTarget(
            name: "SMTPExample",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "MailExampleOpenAPI", package: "mail-example-openapi"),
                .product(name: "FeatherSMTPMail", package: "feather-smtp-mail"),
                .product(name: "NIOSMTP", package: "swift-nio-smtp"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Configuration", package: "swift-configuration"),
                .product(name: "Yams", package: "Yams"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "SMTPExampleTests",
            dependencies: [
                .target(name: "SMTPExample"),
                .product(name: "MailExampleOpenAPI", package: "mail-example-openapi"),
                .product(name: "FeatherMemoryMail", package: "feather-memory-mail"),
            ],
            swiftSettings: defaultSwiftSettings
        )
    ]
)
