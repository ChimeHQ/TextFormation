// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TextFormation",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(name: "TextFormation", targets: ["TextFormation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/Rearrange", from: "1.3.2"),
        .package(url: "https://github.com/ChimeHQ/TextStory.git", .branch("main"))
    ],
    targets: [
        .target(name: "TextFormation", dependencies: ["TextStory"]),
        .testTarget(name: "TextFormationTests", dependencies: ["TextFormation"]),
    ]
)
