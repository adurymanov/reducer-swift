// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReducerSwift",
    platforms: [.iOS(.v16), .macOS(.v14)],
    products: [
        .library(
            name: "ReducerSwift",
            targets: ["ReducerSwift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ReducerSwift",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .testTarget(
            name: "ReducerSwiftTests",
            dependencies: ["ReducerSwift"]
        ),
    ]
)
