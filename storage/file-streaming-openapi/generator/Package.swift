// swift-tools-version:6.1
import PackageDescription

var defaultSwiftSettings: [SwiftSetting] =
[
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableExperimentalFeature("Lifetimes"),
    .enableExperimentalFeature("AvailabilityMacro=fileStreamingOpenAPIGenerator 1.0:macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0"),
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
    name: "file-streaming-openapi-generator",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .executable(name: "FileStreamingOpenAPIGenerator", targets: ["FileStreamingOpenAPIGenerator"]),
    ],
    dependencies: [
        .package(url: "https://github.com/feather-framework/feather-openapi", exact: "1.0.0-beta.4"),
        .package(url: "https://github.com/mattpolzin/OpenAPIKit", from: "5.0.0"),
        .package(url: "https://github.com/jpsim/Yams", from: "6.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "FileStreamingOpenAPIGenerator",
            dependencies: [
                .product(name: "FeatherOpenAPI", package: "feather-openapi"),
                .product(name: "OpenAPIKitCompat", package: "OpenAPIKit"),
                .product(name: "Yams", package: "Yams"),
            ],
            swiftSettings: defaultSwiftSettings
        ),
    ]
)
