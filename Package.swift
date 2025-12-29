// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "KeyNav",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "KeyNav", targets: ["KeyNav"])
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.2.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin-Modern.git", from: "1.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "KeyNav",
            dependencies: [
                "HotKey",
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin-Modern"),
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/KeyNav"
        ),
        .testTarget(
            name: "KeyNavTests",
            dependencies: ["KeyNav"],
            path: "Tests/KeyNavTests"
        )
    ]
)
