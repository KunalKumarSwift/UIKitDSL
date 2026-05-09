// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UIKitDSL",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "UIKitDSL", targets: ["UIKitDSL"]),
        .library(name: "UIKitDSLCore", targets: ["UIKitDSLCore"]),
        .library(name: "UIKitDSLComponents", targets: ["UIKitDSLComponents"]),
        .library(name: "UIKitDSLLayout", targets: ["UIKitDSLLayout"]),
        .library(name: "UIKitDSLArchitecture", targets: ["UIKitDSLArchitecture"]),
        .library(name: "UIKitDSLAnimation", targets: ["UIKitDSLAnimation"]),
    ],
    targets: [
        // MARK: - Source Targets

        .target(
            name: "UIKitDSLCore",
            path: "Sources/UIKitDSLCore"
        ),
        .target(
            name: "UIKitDSLComponents",
            dependencies: ["UIKitDSLCore"],
            path: "Sources/UIKitDSLComponents"
        ),
        .target(
            name: "UIKitDSLLayout",
            dependencies: ["UIKitDSLCore"],
            path: "Sources/UIKitDSLLayout"
        ),
        .target(
            name: "UIKitDSLArchitecture",
            dependencies: ["UIKitDSLCore", "UIKitDSLComponents", "UIKitDSLLayout"],
            path: "Sources/UIKitDSLArchitecture"
        ),
        .target(
            name: "UIKitDSLAnimation",
            dependencies: ["UIKitDSLCore"],
            path: "Sources/UIKitDSLAnimation"
        ),
        .target(
            name: "UIKitDSLHotReload",
            dependencies: ["UIKitDSLCore", "UIKitDSLArchitecture"],
            path: "Sources/UIKitDSLHotReload",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug))
            ]
        ),
        .target(
            name: "UIKitDSL",
            dependencies: [
                "UIKitDSLCore",
                "UIKitDSLComponents",
                "UIKitDSLLayout",
                "UIKitDSLArchitecture",
                "UIKitDSLAnimation",
                "UIKitDSLHotReload",
            ],
            path: "Sources/UIKitDSL"
        ),

        // MARK: - Test Targets

        .testTarget(
            name: "UIKitDSLCoreTests",
            dependencies: ["UIKitDSLCore"],
            path: "Tests/UIKitDSLCoreTests"
        ),
        .testTarget(
            name: "UIKitDSLComponentsTests",
            dependencies: ["UIKitDSLComponents"],
            path: "Tests/UIKitDSLComponentsTests"
        ),
        .testTarget(
            name: "UIKitDSLAnimationTests",
            dependencies: ["UIKitDSLAnimation"],
            path: "Tests/UIKitDSLAnimationTests"
        ),
        .testTarget(
            name: "UIKitDSLArchitectureTests",
            dependencies: ["UIKitDSLArchitecture"],
            path: "Tests/UIKitDSLArchitectureTests"
        ),
    ]
)
