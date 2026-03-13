// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "DesignKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "DesignKit",
            targets: ["DesignKit"]
        ),
        .library(
            name: "DesignKitMetal",
            targets: ["DesignKitMetal"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.15.0")
    ],
    targets: [
        .target(
            name: "DesignKit",
            path: "Sources/DesignKit"
        ),
        .target(
            name: "DesignKitMetal",
            dependencies: ["DesignKit"],
            path: "Sources/DesignKitMetal",
            resources: [
                .process("Shaders")
            ]
        ),
        .target(
            name: "DesignKitExamples",
            dependencies: ["DesignKit"],
            path: "Examples",
            swiftSettings: [
                .define("EXAMPLES_TARGET")
            ]
        ),
        .testTarget(
            name: "DesignKitTests",
            dependencies: [
                "DesignKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Tests/DesignKitTests"
        )
    ]
)
