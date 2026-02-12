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
    .enableExperimentalFeature("AvailabilityMacro=vaporSpecExamplesServer 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
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
    name: "vapor-spec-examples-server",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .executable(name: "VaporSpecExamplesServer", targets: ["VaporSpecExamplesServer"]),
    ],
    dependencies: [
        .package(path: "../../spec-example-openapi"),
        .package(url: "https://github.com/vapor/vapor", from: "4.121.2"),
        .package(url: "https://github.com/feather-framework/feather-vapor-spec", from: "1.0.0-beta.2"),
        .package(url: "https://github.com/feather-framework/feather-spec", from: "1.0.0-beta.2"),
    ],
    targets: [
        .executableTarget(
            name: "VaporSpecExamplesServer",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "SpecExampleOpenAPI", package: "spec-example-openapi"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
        .testTarget(
            name: "VaporSpecExamplesServerTests",
            dependencies: [
                .target(name: "VaporSpecExamplesServer"),
                .product(name: "SpecExampleOpenAPI", package: "spec-example-openapi"),
                .product(name: "FeatherSpec", package: "feather-spec"),
                .product(name: "FeatherVaporSpec", package: "feather-vapor-spec"),
                .product(name: "Vapor", package: "vapor"),
            ],
            swiftSettings: defaultSwiftSettings
        )
    ]
)
