// swift-tools-version: 5.8

import PackageDescription

let package = Package(
	name: "TextFormation",
	platforms: [
		.macOS(.v10_15),
		.macCatalyst(.v13),
		.iOS(.v13),
		.tvOS(.v13),
	],
	products: [
		.library(name: "TextFormation", targets: ["TextFormation"]),
	],
	dependencies: [
		.package(url: "https://github.com/ChimeHQ/Rearrange", branch: "main"),
		.package(url: "https://github.com/ChimeHQ/TextStory", from: "0.9.0"),
	],
	targets: [
		.target(name: "TextFormation", dependencies: ["Rearrange", "TextStory"]),
		.testTarget(name: "TextFormationTests", dependencies: ["TextFormation"]),
	]
)

let swiftSettings: [SwiftSetting] = [
	.enableExperimentalFeature("StrictConcurrency")
]

for target in package.targets {
	var settings = target.swiftSettings ?? []
	settings.append(contentsOf: swiftSettings)
	target.swiftSettings = settings
}
