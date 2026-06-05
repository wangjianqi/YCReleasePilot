// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "YCReleasePilot",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ReleasePilot", targets: ["ReleasePilot"])
    ],
    targets: [
        .executableTarget(
            name: "ReleasePilot",
            path: "Sources/ReleasePilot"
        ),
        .testTarget(
            name: "ReleasePilotTests",
            dependencies: ["ReleasePilot"],
            path: "Tests/ReleasePilotTests"
        )
    ]
)
