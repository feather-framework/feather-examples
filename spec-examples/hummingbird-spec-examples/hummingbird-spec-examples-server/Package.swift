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
    .enableExperimentalFeature("AvailabilityMacro=hummingbirdSpecExamplesServer 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
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
    name: "hummingbird-spec-examples-server",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .executable(name: "HummingbirdSpecExamplesServer", targets: ["HummingbirdSpecExamplesServer"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/hummingbird-project/hummingbird",
            from: "2.0.0"
        ),
        .package(
            url: "https://github.com/hummingbird-project/swift-openapi-hummingbird",
            from: "2.0.1"
        ),
        .package(path: "../../spec-example-openapi"),
        .package(path: "../../../../feather-hummingbird-spec"),
        .package(path: "../../../../feather-spec"),
    ],
    targets: [
        .executableTarget(
            name: "HummingbirdSpecExamplesServer",
            dependencies: [
                .product(name: "Hummingbird", package: "hummingbird"),
                .product(name: "OpenAPIHummingbird", package: "swift-openapi-hummingbird"),
                .product(name: "SpecExampleOpenAPI", package: "spec-example-openapi"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "HummingbirdSpecExamplesServerTests",
            dependencies: [
                .target(name: "HummingbirdSpecExamplesServer"),
                .product(name: "SpecExampleOpenAPI", package: "spec-example-openapi"),
                .product(name: "FeatherSpec", package: "feather-spec"),
                .product(name: "FeatherHummingbirdSpec", package: "feather-hummingbird-spec"),
            ],
            swiftSettings: defaultSwiftSettings
        )
    ]
)
