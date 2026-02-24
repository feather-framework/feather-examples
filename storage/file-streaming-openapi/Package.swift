// swift-tools-version:6.1
import PackageDescription

// NOTE: https://github.com/swift-server/swift-http-server/blob/main/Package.swift
var defaultSwiftSettings: [SwiftSetting] =
[
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableExperimentalFeature("Lifetimes"),
    .enableExperimentalFeature("AvailabilityMacro=example 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
]

#if compiler(>=6.2)
defaultSwiftSettings.append(
    .enableUpcomingFeature("NonisolatedNonsendingByDefault")
)
#endif

defaultSwiftSettings += [
    .enableExperimentalFeature("StrictConcurrency=complete"),
    .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release)),
]

let package = Package(
    name: "file-streaming-openapi",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "FileStreamingOpenAPI", targets: ["FileStreamingOpenAPI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.9.0"),
    ],
    targets: [
        .target(
            name: "FileStreamingOpenAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ],
            swiftSettings: defaultSwiftSettings
        )
    ]
)
