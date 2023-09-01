// swift-tools-version: 5.8

import PackageDescription

let settings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency")
]

let package = Package(
    name: "TextFormation",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .library(name: "TextFormation", targets: ["TextFormation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ChimeHQ/TextStory", from: "0.8.0")
    ],
    targets: [
        .target(name: "TextFormation", dependencies: ["TextStory"], swiftSettings: settings),
        .testTarget(name: "TextFormationTests", dependencies: ["TextFormation"], swiftSettings: settings),
    ]
)
