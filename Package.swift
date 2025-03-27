// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "nootch",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "nootch"),
    ]
)
