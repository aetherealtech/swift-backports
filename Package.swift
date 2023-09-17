// swift-tools-version: 5.8

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
        .package(path: "../Synchronization")
    ],
    targets: [
        .target(
            name: "Backports",
            dependencies: [
                "NativeBridge",
                .product(name: "Synchronization", package: "Synchronization"),
            ],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .target(
            name: "NativeBridge",
            dependencies: [],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
        .testTarget(
            name: "BackportsTests",
            dependencies: ["Backports"],
            swiftSettings: [.concurrencyChecking(.complete)]
        ),
    ]
)

extension SwiftSetting {
    enum ConcurrencyChecking: String {
        case complete
        case minimal
        case targeted
    }
    
    static func concurrencyChecking(_ setting: ConcurrencyChecking = .minimal) -> Self {
        unsafeFlags([
            "-Xfrontend", "-strict-concurrency=\(setting)",
            "-Xfrontend", "-warn-concurrency",
            "-Xfrontend", "-enable-actor-data-race-checks",
        ])
    }
}
