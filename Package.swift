// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TextFormation",
    platforms: [.macOS(.v10_12), .iOS(.v10)],
    products: [
        .library(name: "TextFormation", targets: ["TextFormation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/TextStory", from: "0.7.1"),
        .package(url: "https://github.com/ChimeHQ/Rearrange", from: "1.5.2")
    ],
    targets: [
        .target(name: "TextFormation", dependencies: ["TextStory"]),
        .testTarget(name: "TextFormationTests", dependencies: ["TextFormation", "Rearrange"]),
    ]
)
