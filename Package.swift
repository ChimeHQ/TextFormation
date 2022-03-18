// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TextFormation",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(name: "TextFormation", targets: ["TextFormation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/TextStory", from: "0.7.0")
    ],
    targets: [
        .target(name: "TextFormation", dependencies: ["TextStory"]),
        .testTarget(name: "TextFormationTests", dependencies: ["TextFormation"]),
    ]
)
