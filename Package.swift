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
    dependencies: [
        .package(url: "https://github.com/synth-inc/LLMStream", revision: "57c2887ee63a25fbf10983b6b2be480b717e432a"),
        .package(url: "https://github.com/EnesKaraosman/SwiftyChat.git", from: "4.1.1")
    ],
    targets: [
        .executableTarget(
            name: "ReleasePilot",
            dependencies: [
                .product(name: "LLMStream", package: "LLMStream"),
                .product(name: "SwiftyChat", package: "SwiftyChat")
            ],
            path: "Sources/ReleasePilot"
        ),
        .testTarget(
            name: "ReleasePilotTests",
            dependencies: ["ReleasePilot"],
            path: "Tests/ReleasePilotTests"
        )
    ]
)
