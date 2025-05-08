// swift-tools-version: 6.0

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
	],
	targets: [
		.target(name: "TextFormation", dependencies: ["Rearrange"]),
		.testTarget(name: "TextFormationTests", dependencies: ["TextFormation"]),
	]
)
