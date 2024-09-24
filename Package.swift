// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Backports",
    products: [
        .library(
            name: "Backports",
            targets: ["Backports"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/aetherealtech/swift-synchronization", branch: "master"),
    ],
    targets: [
        .target(
            name: "Backports",
            dependencies: [
                "NativeBridge",
                .product(name: "Synchronization", package: "swift-synchronization"),
            ]
        ),
        .target(
            name: "NativeBridge",
            dependencies: []
        ),
        .testTarget(
            name: "BackportsTests",
            dependencies: ["Backports"]
        ),
    ]
)
